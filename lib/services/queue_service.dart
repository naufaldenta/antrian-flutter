import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/formatters.dart';
import '../core/security.dart';
import '../data/dummy_data.dart';
import '../data/local_storage.dart';
import '../data/models.dart';

class QueueService extends ChangeNotifier {
  QueueService(
    this._storage, {
    DateTime Function()? clock,
    this.tickInterval = const Duration(seconds: 30),
  }) : _now = clock ?? DateTime.now;

  final LocalStorage _storage;
  final DateTime Function() _now;
  final Duration tickInterval;

  static const bookingWindowDays = 7;
  static const maxActiveTickets = 3;
  static const nearTurnThreshold = 3;

  static const callHoldTicks = 3;

  List<Ticket> _tickets = [];
  Map<String, int> _servingToday = {};
  final Map<String, int> _holdTicks = {};
  Timer? _timer;

  String? watchedPatientId;

  final ValueNotifier<String?> alert = ValueNotifier(null);
  final Set<String> _alertedTickets = {};

  DateTime get today => Fmt.dateOnly(_now());

  String get _servingKey {
    final d = today;
    return 'serving_${d.year}-${d.month}-${d.day}';
  }

  Future<void> init({bool startTimer = true}) async {
    _tickets = _storage
        .readList(LocalStorage.kTickets)
        .map(Ticket.fromJson)
        .toList();
    final raw = _storage.readString(_servingKey);
    _servingToday = raw == null
        ? {}
        : (jsonDecode(raw) as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v as int),
          );
    await _seedDemoHistory();
    if (startTimer) {
      _timer = Timer.periodic(tickInterval, (_) => advanceAll());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    alert.dispose();
    super.dispose();
  }

  Future<void> _seedDemoHistory() async {
    if (_tickets.any((t) => t.patientId == 'demo-patient')) return;
    Ticket seed(
      String id,
      String poliId,
      String doctorId,
      int daysAgo,
      int number,
      String complaint, {
      bool cancelled = false,
    }) {
      final date = _practiceDayOnOrBefore(
        doctorId,
        today.subtract(Duration(days: daysAgo)),
      );
      return Ticket(
        id: id,
        patientId: 'demo-patient',
        poliId: poliId,
        doctorId: doctorId,
        visitDate: date,
        number: number,
        complaint: complaint,
        createdAt: date.subtract(const Duration(days: 1)),
        cancelled: cancelled,
      );
    }

    _tickets.addAll([
      seed('seed-1', 'umum', 'd1', 45, 12, 'Demam dan batuk selama 3 hari'),
      seed('seed-2', 'gigi', 'd3', 20, 5, 'Sakit gigi geraham kanan bawah'),
      seed(
        'seed-3',
        'umum',
        'd1',
        8,
        18,
        'Kontrol tekanan darah',
        cancelled: true,
      ),
    ]);
    await _saveTickets();
  }

  DateTime _practiceDayOnOrBefore(String doctorId, DateTime date) {
    final doctor = DummyData.doctorById(doctorId);
    var d = date;
    while (!doctor.practicesOn(d)) {
      d = d.subtract(const Duration(days: 1));
    }
    return d;
  }

  Future<void> _saveTickets() => _storage.writeList(
    LocalStorage.kTickets,
    _tickets.map((t) => t.toJson()).toList(),
  );

  Future<void> _saveServing() =>
      _storage.writeString(_servingKey, jsonEncode(_servingToday));

  List<Ticket> _ticketsFor(String doctorId, DateTime date) => _tickets
      .where((t) => t.doctorId == doctorId && Fmt.sameDay(t.visitDate, date))
      .toList();

  int lastNumber(String doctorId, DateTime date) =>
      DummyData.simulatedOtherPatients(doctorId, date) +
      _ticketsFor(doctorId, date).length;

  int remainingQuota(String doctorId, DateTime date) =>
      (DummyData.doctorById(doctorId).dailyQuota - lastNumber(doctorId, date))
          .clamp(0, 9999);

  int servingNumber(String doctorId) {
    return _servingToday[doctorId] ??
        (DummyData.simulatedOtherPatients(doctorId, today) * 0.6).floor().clamp(
          1,
          999,
        );
  }

  bool _isDoctorOpenNow(Doctor d) {
    final now = _now();
    final parts = d.endTime.split(':').map(int.parse).toList();
    final end = DateTime(now.year, now.month, now.day, parts[0], parts[1]);
    return now.isBefore(end);
  }

  List<DateTime> bookableDates() =>
      List.generate(bookingWindowDays, (i) => today.add(Duration(days: i)));

  String? doctorUnavailableReason(Doctor d, DateTime date) {
    if (!d.practicesOn(date)) {
      return 'Tidak praktik hari ${Fmt.dayName(date.weekday)}';
    }
    if (Fmt.sameDay(date, today) && !_isDoctorOpenNow(d)) {
      return 'Jam praktik hari ini sudah berakhir';
    }
    if (remainingQuota(d.id, date) <= 0) return 'Kuota penuh';
    return null;
  }

  TicketStatus statusOf(Ticket t) {
    if (t.cancelled) return TicketStatus.dibatalkan;
    final d = Fmt.dateOnly(t.visitDate);
    if (d.isAfter(today)) return TicketStatus.terjadwal;
    if (d.isBefore(today)) return TicketStatus.selesai;
    final serving = servingNumber(t.doctorId);
    if (serving < t.number) return TicketStatus.menunggu;
    if (serving == t.number) return TicketStatus.dipanggil;
    return TicketStatus.selesai;
  }

  bool isActive(Ticket t) {
    final s = statusOf(t);
    return s == TicketStatus.terjadwal ||
        s == TicketStatus.menunggu ||
        s == TicketStatus.dipanggil;
  }

  int peopleAhead(Ticket t) {
    if (Fmt.sameDay(t.visitDate, today)) {
      return (t.number - servingNumber(t.doctorId)).clamp(0, 9999);
    }
    return t.number - 1;
  }

  int estimatedWaitMinutes(Ticket t) =>
      peopleAhead(t) * DummyData.poliById(t.poliId).avgServiceMinutes;

  List<Ticket> activeTicketsOf(String patientId) =>
      _tickets.where((t) => t.patientId == patientId && isActive(t)).toList()
        ..sort((a, b) => a.visitDate.compareTo(b.visitDate));

  List<Ticket> historyOf(String patientId) =>
      _tickets.where((t) => t.patientId == patientId && !isActive(t)).toList()
        ..sort((a, b) => b.visitDate.compareTo(a.visitDate));

  Ticket? byId(String id) => _tickets.where((t) => t.id == id).firstOrNull;

  Future<(Ticket?, String?)> takeTicket({
    required String patientId,
    required String poliId,
    required String doctorId,
    required DateTime date,
    required String complaint,
  }) async {
    final visitDate = Fmt.dateOnly(date);
    final doctor = DummyData.doctorById(doctorId);
    if (doctor.poliId != poliId) {
      return (null, 'Dokter tidak sesuai dengan poli yang dipilih.');
    }
    final lastDay = today.add(const Duration(days: bookingWindowDays - 1));
    if (visitDate.isBefore(today) || visitDate.isAfter(lastDay)) {
      return (
        null,
        'Tanggal kunjungan harus antara hari ini dan $bookingWindowDays hari ke depan.',
      );
    }
    final reason = doctorUnavailableReason(doctor, visitDate);
    if (reason != null) return (null, reason);

    final active = activeTicketsOf(patientId);
    if (active.any(
      (t) => t.poliId == poliId && Fmt.sameDay(t.visitDate, visitDate),
    )) {
      return (
        null,
        'Anda sudah memiliki antrean di poli ini pada tanggal tersebut.',
      );
    }
    if (active.length >= maxActiveTickets) {
      return (
        null,
        'Maksimal $maxActiveTickets antrean aktif. Batalkan salah satu terlebih dahulu.',
      );
    }

    final ticket = Ticket(
      id: Security.newId(),
      patientId: patientId,
      poliId: poliId,
      doctorId: doctorId,
      visitDate: visitDate,
      number: lastNumber(doctorId, visitDate) + 1,
      complaint: complaint.trim(),
      createdAt: _now(),
    );
    _tickets.add(ticket);
    await _saveTickets();
    notifyListeners();
    return (ticket, null);
  }

  Future<String?> cancelTicket(String id) async {
    final t = byId(id);
    if (t == null) return 'Antrean tidak ditemukan.';
    final s = statusOf(t);
    if (s == TicketStatus.dipanggil) {
      return 'Nomor Anda sedang dipanggil, tidak dapat dibatalkan.';
    }
    if (s != TicketStatus.terjadwal && s != TicketStatus.menunggu) {
      return 'Antrean ini sudah tidak aktif.';
    }
    _tickets = [
      for (final x in _tickets) x.id == id ? x.copyWith(cancelled: true) : x,
    ];
    await _saveTickets();
    notifyListeners();
    return null;
  }

  Future<void> advanceAll() async {
    for (final d in DummyData.doctors.where((d) => d.practicesOn(today))) {
      final hold = _holdTicks[d.id] ?? 0;
      if (hold > 0) {
        _holdTicks[d.id] = hold - 1;
        continue;
      }
      _advance(d.id);
    }
    await _saveServing();
    _checkNearTurn();
    notifyListeners();
  }

  Future<void> advanceDoctor(String doctorId) async {
    _advance(doctorId);
    await _saveServing();
    _checkNearTurn();
    notifyListeners();
  }

  void _advance(String doctorId) {
    final current = servingNumber(doctorId);
    if (current <= lastNumber(doctorId, today)) {
      final next = current + 1;
      _servingToday[doctorId] = next;
      final isAppUser = _tickets.any(
        (t) =>
            t.doctorId == doctorId &&
            !t.cancelled &&
            t.number == next &&
            Fmt.sameDay(t.visitDate, today),
      );
      _holdTicks[doctorId] = isAppUser ? callHoldTicks : 0;
    }
  }

  void _checkNearTurn() {
    final pid = watchedPatientId;
    if (pid == null) return;
    for (final t in activeTicketsOf(pid)) {
      if (!Fmt.sameDay(t.visitDate, today)) continue;
      final poli = DummyData.poliById(t.poliId);
      final number = Fmt.queueNumber(poli.code, t.number);
      final status = statusOf(t);
      if (status == TicketStatus.dipanggil &&
          _alertedTickets.add('${t.id}-call')) {
        alert.value = 'Nomor $number dipanggil! Silakan menuju ${poli.name}.';
      } else if (status == TicketStatus.menunggu &&
          peopleAhead(t) <= nearTurnThreshold &&
          _alertedTickets.add('${t.id}-near')) {
        alert.value =
            'Giliran $number sebentar lagi '
            '(${peopleAhead(t)} antrean lagi). Bersiaplah di ruang tunggu.';
      }
    }
  }

  Future<void> removePatientData(String patientId) async {
    _tickets.removeWhere((t) => t.patientId == patientId);
    await _saveTickets();
    notifyListeners();
  }
}

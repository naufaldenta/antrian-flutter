import 'package:flutter/foundation.dart';

import '../core/security.dart';
import '../data/local_storage.dart';
import '../data/models.dart';

class ReminderService extends ChangeNotifier {
  ReminderService(this._storage, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final LocalStorage _storage;
  final DateTime Function() _now;

  List<Reminder> _items = [];

  Future<void> init() async {
    _items = _storage
        .readList(LocalStorage.kReminders)
        .map(Reminder.fromJson)
        .toList();
    if (!_items.any((r) => r.patientId == 'demo-patient')) {
      final base = _now();
      _items.add(
        Reminder(
          id: 'seed-r1',
          patientId: 'demo-patient',
          title: 'Kontrol tekanan darah',
          note: 'Bawa buku catatan tensi dan kartu berobat.',
          dateTime: DateTime(base.year, base.month, base.day + 5, 8, 0),
        ),
      );
      await _save();
    }
    notifyListeners();
  }

  Future<void> _save() => _storage.writeList(
    LocalStorage.kReminders,
    _items.map((r) => r.toJson()).toList(),
  );

  List<Reminder> upcomingOf(String patientId) =>
      _items.where((r) => r.patientId == patientId && !r.done).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<Reminder> doneOf(String patientId) =>
      _items.where((r) => r.patientId == patientId && r.done).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  Future<String?> add({
    required String patientId,
    required String title,
    required String note,
    required DateTime dateTime,
  }) async {
    if (!dateTime.isAfter(_now())) {
      return 'Waktu pengingat harus di masa depan.';
    }
    _items.add(
      Reminder(
        id: Security.newId(),
        patientId: patientId,
        title: title.trim(),
        note: note.trim(),
        dateTime: dateTime,
      ),
    );
    await _save();
    notifyListeners();
    return null;
  }

  Future<void> toggleDone(String id) async {
    _items = [
      for (final r in _items) r.id == id ? r.copyWith(done: !r.done) : r,
    ];
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((r) => r.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> removePatientData(String patientId) async {
    _items.removeWhere((r) => r.patientId == patientId);
    await _save();
    notifyListeners();
  }
}

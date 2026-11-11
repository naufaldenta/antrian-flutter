import 'package:flutter/foundation.dart';

import '../core/security.dart';
import '../data/dummy_data.dart';
import '../data/local_storage.dart';
import '../data/models.dart';

class AuthService extends ChangeNotifier {
  AuthService(this._storage, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final LocalStorage _storage;
  final DateTime Function() _now;

  static const maxFailedAttempts = 5;
  static const lockDuration = Duration(seconds: 60);

  List<Patient> _patients = [];
  Patient? _current;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  Patient? get current => _current;
  bool get isLoggedIn => _current != null;

  Future<void> init() async {
    _patients = _storage
        .readList(LocalStorage.kPatients)
        .map(Patient.fromJson)
        .toList();
    if (!_patients.any((p) => p.nik == DummyData.demoNik)) {
      final salt = Security.generateSalt();
      _patients.add(
        Patient(
          id: 'demo-patient',
          nik: DummyData.demoNik,
          name: 'Budi Setiawan',
          birthDate: DateTime(1990, 1, 1),
          gender: 'L',
          phone: '081234567890',
          address: 'Jl. Melati No. 10, RT 02/RW 05, Kel. Sukamaju',
          passwordHash: Security.hashPassword(DummyData.demoPassword, salt),
          salt: salt,
          consentAt: _now(),
        ),
      );
      await _save();
    }
    final sessionId = _storage.readString(LocalStorage.kSession);
    if (sessionId != null) {
      _current = _patients.where((p) => p.id == sessionId).firstOrNull;
    }
    notifyListeners();
  }

  Future<void> _save() => _storage.writeList(
    LocalStorage.kPatients,
    _patients.map((p) => p.toJson()).toList(),
  );

  Future<String?> register({
    required String nik,
    required String name,
    required DateTime birthDate,
    required String gender,
    required String phone,
    required String address,
    required String password,
  }) async {
    if (_patients.any((p) => p.nik == nik.trim())) {
      return 'NIK sudah terdaftar. Silakan masuk dengan akun Anda.';
    }
    final salt = Security.generateSalt();
    final patient = Patient(
      id: Security.newId(),
      nik: nik.trim(),
      name: name.trim(),
      birthDate: birthDate,
      gender: gender,
      phone: phone.replaceAll(RegExp(r'[\s-]'), ''),
      address: address.trim(),
      passwordHash: Security.hashPassword(password, salt),
      salt: salt,
      consentAt: _now(),
    );
    _patients.add(patient);
    await _save();
    await _startSession(patient);
    return null;
  }

  Duration? get lockRemaining {
    final until = _lockedUntil;
    if (until == null) return null;
    final left = until.difference(_now());
    return left.isNegative ? null : left;
  }

  Future<String?> login(String nik, String password) async {
    final remaining = lockRemaining;
    if (remaining != null) {
      return 'Terlalu banyak percobaan gagal. Coba lagi dalam '
          '${remaining.inSeconds + 1} detik.';
    }
    final patient = _patients.where((p) => p.nik == nik.trim()).firstOrNull;
    final ok =
        patient != null &&
        Security.verifyPassword(password, patient.salt, patient.passwordHash);
    if (!ok) {
      _failedAttempts++;
      if (_failedAttempts >= maxFailedAttempts) {
        _failedAttempts = 0;
        _lockedUntil = _now().add(lockDuration);
        return 'Login dikunci sementara selama ${lockDuration.inSeconds} detik '
            'karena $maxFailedAttempts kali gagal.';
      }
      return 'NIK atau password salah '
          '(sisa percobaan: ${maxFailedAttempts - _failedAttempts}).';
    }
    _failedAttempts = 0;
    _lockedUntil = null;
    await _startSession(patient);
    return null;
  }

  Future<void> _startSession(Patient p) async {
    _current = p;
    await _storage.writeString(LocalStorage.kSession, p.id);
    notifyListeners();
  }

  Future<void> logout() async {
    _current = null;
    await _storage.remove(LocalStorage.kSession);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    final cur = _current;
    if (cur == null) return;
    final updated = cur.copyWith(
      name: name.trim(),
      phone: phone.replaceAll(RegExp(r'[\s-]'), ''),
      address: address.trim(),
    );
    _patients = [for (final p in _patients) p.id == cur.id ? updated : p];
    _current = updated;
    await _save();
    notifyListeners();
  }

  Future<void> deleteCurrentAccount() async {
    final cur = _current;
    if (cur == null) return;
    _patients.removeWhere((p) => p.id == cur.id);
    await _save();
    await logout();
  }
}

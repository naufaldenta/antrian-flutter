import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static const kPatients = 'patients';
  static const kSession = 'session_patient_id';
  static const kTickets = 'tickets';
  static const kReminders = 'reminders';

  static Future<LocalStorage> open() async =>
      LocalStorage(await SharedPreferences.getInstance());

  List<Map<String, dynamic>> readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> items) =>
      _prefs.setString(key, jsonEncode(items));

  String? readString(String key) => _prefs.getString(key);

  Future<void> writeString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
}

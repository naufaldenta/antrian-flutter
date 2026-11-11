import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class Security {
  Security._();

  static final _random = Random.secure();

  static String generateSalt([int length = 16]) {
    final bytes = List<int>.generate(length, (_) => _random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String hashPassword(String password, String salt) {
    List<int> digest = utf8.encode('$salt$password');
    for (var i = 0; i < 1000; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64Url.encode(digest);
  }

  static bool verifyPassword(String password, String salt, String hash) =>
      hashPassword(password, salt) == hash;

  static String maskNik(String nik) {
    if (nik.length < 8) return '*' * nik.length;
    return '${nik.substring(0, 4)}${'*' * (nik.length - 8)}${nik.substring(nik.length - 4)}';
  }

  static String maskPhone(String phone) {
    if (phone.length < 8) return phone;
    return '${phone.substring(0, 4)}${'*' * (phone.length - 8)}${phone.substring(phone.length - 4)}';
  }

  static String newId() =>
      '${DateTime.now().microsecondsSinceEpoch}${_random.nextInt(9999)}';
}

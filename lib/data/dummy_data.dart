import 'package:flutter/material.dart';

import 'models.dart';

class DummyData {
  DummyData._();

  static const String facilityName = 'Puskesmas Sehat Sentosa (Simulasi)';

  static const List<Poli> polis = [
    Poli(
      id: 'umum',
      code: 'U',
      name: 'Poli Umum',
      description: 'Pemeriksaan dan pengobatan penyakit umum untuk dewasa.',
      avgServiceMinutes: 10,
      icon: Icons.medical_services,
      color: Color(0xFF007AFF),
    ),
    Poli(
      id: 'gigi',
      code: 'G',
      name: 'Poli Gigi',
      description: 'Pemeriksaan, penambalan, dan pencabutan gigi.',
      avgServiceMinutes: 20,
      icon: Icons.sentiment_satisfied_alt,
      color: Color(0xFF30B0C7),
    ),
    Poli(
      id: 'kia',
      code: 'K',
      name: 'Poli KIA & KB',
      description: 'Pemeriksaan ibu hamil, imunisasi anak, dan layanan KB.',
      avgServiceMinutes: 15,
      icon: Icons.pregnant_woman,
      color: Color(0xFFFF2D55),
    ),
    Poli(
      id: 'anak',
      code: 'A',
      name: 'Poli Anak (MTBS)',
      description: 'Manajemen terpadu balita sakit untuk usia 0–5 tahun.',
      avgServiceMinutes: 12,
      icon: Icons.child_care,
      color: Color(0xFFFF9500),
    ),
    Poli(
      id: 'lansia',
      code: 'L',
      name: 'Poli Lansia',
      description: 'Pemeriksaan rutin dan penyakit kronis untuk usia 60+.',
      avgServiceMinutes: 12,
      icon: Icons.elderly,
      color: Color(0xFF5856D6),
    ),
  ];

  static const List<Doctor> doctors = [
    Doctor(
      id: 'd1',
      poliId: 'umum',
      name: 'dr. Andi Pratama',
      days: [1, 2, 3, 4, 5, 6],
      startTime: '08:00',
      endTime: '12:00',
      dailyQuota: 40,
    ),
    Doctor(
      id: 'd2',
      poliId: 'umum',
      name: 'dr. Sari Wulandari',
      days: [1, 3, 5],
      startTime: '13:00',
      endTime: '16:00',
      dailyQuota: 25,
    ),
    Doctor(
      id: 'd3',
      poliId: 'gigi',
      name: 'drg. Budi Santoso',
      days: [1, 2, 4, 6],
      startTime: '08:00',
      endTime: '12:00',
      dailyQuota: 15,
    ),
    Doctor(
      id: 'd4',
      poliId: 'kia',
      name: 'Bidan Rina Kusuma, A.Md.Keb',
      days: [1, 2, 3, 4, 5],
      startTime: '08:00',
      endTime: '13:00',
      dailyQuota: 30,
    ),
    Doctor(
      id: 'd5',
      poliId: 'anak',
      name: 'dr. Maya Lestari',
      days: [2, 4, 6],
      startTime: '08:00',
      endTime: '12:00',
      dailyQuota: 25,
    ),
    Doctor(
      id: 'd6',
      poliId: 'lansia',
      name: 'dr. Hendra Gunawan',
      days: [1, 3, 5, 6],
      startTime: '08:00',
      endTime: '12:00',
      dailyQuota: 30,
    ),
  ];

  static Poli poliById(String id) => polis.firstWhere((p) => p.id == id);

  static Doctor doctorById(String id) => doctors.firstWhere((d) => d.id == id);

  static List<Doctor> doctorsOf(String poliId) =>
      doctors.where((d) => d.poliId == poliId).toList();

  static int simulatedOtherPatients(String doctorId, DateTime date) {
    final seed =
        doctorId.codeUnits.fold<int>(0, (a, b) => a + b) +
        date.day * 7 +
        date.month * 3;
    final quota = doctorById(doctorId).dailyQuota;
    final max = (quota * 0.4).floor().clamp(3, 15);
    return 4 + seed % (max - 3);
  }

  static const String demoNik = '3201010101900001';
  static const String demoPassword = 'Demo1234';
}

import 'package:flutter/widgets.dart' show Color, IconData;

class Patient {
  final String id;
  final String nik;
  final String name;
  final DateTime birthDate;
  final String gender; // 'L' atau 'P'
  final String phone;
  final String address;
  final String passwordHash;
  final String salt;
  final DateTime consentAt;

  const Patient({
    required this.id,
    required this.nik,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.phone,
    required this.address,
    required this.passwordHash,
    required this.salt,
    required this.consentAt,
  });

  Patient copyWith({String? name, String? phone, String? address}) => Patient(
    id: id,
    nik: nik,
    name: name ?? this.name,
    birthDate: birthDate,
    gender: gender,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    passwordHash: passwordHash,
    salt: salt,
    consentAt: consentAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nik': nik,
    'name': name,
    'birthDate': birthDate.toIso8601String(),
    'gender': gender,
    'phone': phone,
    'address': address,
    'passwordHash': passwordHash,
    'salt': salt,
    'consentAt': consentAt.toIso8601String(),
  };

  factory Patient.fromJson(Map<String, dynamic> j) => Patient(
    id: j['id'] as String,
    nik: j['nik'] as String,
    name: j['name'] as String,
    birthDate: DateTime.parse(j['birthDate'] as String),
    gender: j['gender'] as String,
    phone: j['phone'] as String,
    address: j['address'] as String,
    passwordHash: j['passwordHash'] as String,
    salt: j['salt'] as String,
    consentAt: DateTime.parse(j['consentAt'] as String),
  );
}

class Poli {
  final String id;
  final String code; // prefix nomor antrean, mis. "U"
  final String name;
  final String description;
  final int avgServiceMinutes;
  final IconData icon;
  final Color color;

  const Poli({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.avgServiceMinutes,
    required this.icon,
    required this.color,
  });
}

class Doctor {
  final String id;
  final String poliId;
  final String name;

  final List<int> days;
  final String startTime; // "08:00"
  final String endTime; // "12:00"
  final int dailyQuota;

  const Doctor({
    required this.id,
    required this.poliId,
    required this.name,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.dailyQuota,
  });

  bool practicesOn(DateTime date) => days.contains(date.weekday);
}

enum TicketStatus { terjadwal, menunggu, dipanggil, selesai, dibatalkan }

extension TicketStatusLabel on TicketStatus {
  String get label => switch (this) {
    TicketStatus.terjadwal => 'Terjadwal',
    TicketStatus.menunggu => 'Menunggu',
    TicketStatus.dipanggil => 'Dipanggil',
    TicketStatus.selesai => 'Selesai',
    TicketStatus.dibatalkan => 'Dibatalkan',
  };
}

class Ticket {
  final String id;
  final String patientId;
  final String poliId;
  final String doctorId;
  final DateTime visitDate;
  final int number;
  final String complaint;
  final DateTime createdAt;
  final bool cancelled;

  const Ticket({
    required this.id,
    required this.patientId,
    required this.poliId,
    required this.doctorId,
    required this.visitDate,
    required this.number,
    required this.complaint,
    required this.createdAt,
    this.cancelled = false,
  });

  Ticket copyWith({bool? cancelled}) => Ticket(
    id: id,
    patientId: patientId,
    poliId: poliId,
    doctorId: doctorId,
    visitDate: visitDate,
    number: number,
    complaint: complaint,
    createdAt: createdAt,
    cancelled: cancelled ?? this.cancelled,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'poliId': poliId,
    'doctorId': doctorId,
    'visitDate': visitDate.toIso8601String(),
    'number': number,
    'complaint': complaint,
    'createdAt': createdAt.toIso8601String(),
    'cancelled': cancelled,
  };

  factory Ticket.fromJson(Map<String, dynamic> j) => Ticket(
    id: j['id'] as String,
    patientId: j['patientId'] as String,
    poliId: j['poliId'] as String,
    doctorId: j['doctorId'] as String,
    visitDate: DateTime.parse(j['visitDate'] as String),
    number: j['number'] as int,
    complaint: j['complaint'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String),
    cancelled: j['cancelled'] as bool? ?? false,
  );
}

class Reminder {
  final String id;
  final String patientId;
  final String title;
  final String note;
  final DateTime dateTime;
  final bool done;

  const Reminder({
    required this.id,
    required this.patientId,
    required this.title,
    required this.note,
    required this.dateTime,
    this.done = false,
  });

  Reminder copyWith({bool? done}) => Reminder(
    id: id,
    patientId: patientId,
    title: title,
    note: note,
    dateTime: dateTime,
    done: done ?? this.done,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'title': title,
    'note': note,
    'dateTime': dateTime.toIso8601String(),
    'done': done,
  };

  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(
    id: j['id'] as String,
    patientId: j['patientId'] as String,
    title: j['title'] as String,
    note: j['note'] as String,
    dateTime: DateTime.parse(j['dateTime'] as String),
    done: j['done'] as bool? ?? false,
  );
}

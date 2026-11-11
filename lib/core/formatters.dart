class Fmt {
  Fmt._();

  static const _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String dayName(int weekday) => _days[weekday - 1];

  static String shortDay(int weekday) => _days[weekday - 1].substring(0, 3);

  static String fullDate(DateTime d) =>
      '${dayName(d.weekday)}, ${d.day} ${_months[d.month - 1]} ${d.year}';

  static String shortDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1].substring(0, 3)} ${d.year}';

  static String time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String queueNumber(String code, int n) =>
      '$code-${n.toString().padLeft(3, '0')}';

  static String duration(int minutes) {
    if (minutes <= 0) return 'Segera';
    if (minutes < 60) return '± $minutes menit';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '± $h jam' : '± $h jam $m menit';
  }

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String days(List<int> weekdays) => weekdays.map(shortDay).join(', ');
}

import 'package:flutter/material.dart' show TimeOfDay;

class Fmt {
  Fmt._();

  static const _monthShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];
  static const _monthLong = [
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
    'Desember'
  ];
  static const _dayLong = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String isoDate(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';
  static String hhmm(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';
  static String clock(TimeOfDay t) => '${_two(t.hour)}.${_two(t.minute)}';

  static String shortOf(DateTime d) => '${d.day} ${_monthShort[d.month - 1]}';
  static String fullOf(DateTime d) =>
      '${d.day} ${_monthShort[d.month - 1]} ${d.year}';

  static String shortDate(String iso) {
    final d = DateTime.tryParse(iso);
    return d == null ? iso : shortOf(d);
  }

  static String longDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${_dayLong[d.weekday - 1]}, ${d.day} ${_monthLong[d.month - 1]} ${d.year}';
  }

  /// "09:00 - 13:00" -> "09.00–13.00"
  static String timeRange(String t) =>
      t.replaceAll(':', '.').replaceAll(' - ', '–');

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  static TimeOfDay? parseTime(String s) {
    final p = s.trim().split(':');
    if (p.length != 2) return null;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static List<String> groups(String s) =>
      s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  static bool acceptsAll(String s) =>
      s.toLowerCase().contains('semua') || groups(s).length >= 8;

  static String badge(String s) {
    if (acceptsAll(s)) return 'Semua';
    final g = groups(s);
    return g.isEmpty ? '-' : g.first;
  }

  static String distance(double km) =>
      '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
}

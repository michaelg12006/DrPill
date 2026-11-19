
import 'dart:async';
import 'package:dr_drugs/utils/colors.dart';
import 'package:flutter/material.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late DateTime _now;
  Timer? _timer;

  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _months = [
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

  @override
  void initState() {
    super.initState();

    _now = DateTime.now();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        final currentTime = DateTime.now();
        if (currentTime.minute != _now.minute ||
            currentTime.day != _now.day ||
            currentTime.month != _now.month ||
            currentTime.year != _now.year ||
            currentTime.hour != _now.hour) {
          setState(() {
            _now = currentTime;
          });
        }
      },
    );
  }

  bool get _isNight {
    return _now.hour >= 18 || _now.hour < 6;
  }

  String get _formattedTime {
    final hour = _now.hour.toString().padLeft(2, '0');
    final minute = _now.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String get _formattedDate {
    final day = _days[_now.weekday - 1];
    final date = _now.day;
    final month = _months[_now.month - 1];
    final year = _now.year;

    return '$day, $date $month $year';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clockColor = const Color(0xFFFFFEFA);

    final accentColor = _isNight
    ? const Color(0xFF6487E0)
    : const Color(0xFFECC842);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: clockColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isNight ? 0.2 : 0.05,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Icon(
                    _isNight
                        ? Icons.nightlight_round
                        : Icons.wb_sunny_rounded,
                    key: ValueKey(_isNight),
                    size: 48,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _formattedTime,
                    key: ValueKey(_formattedTime),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                      color: primaryFontColor,
                      height: 1.1,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _formattedDate,
              key: ValueKey(_formattedDate),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: primaryFontColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

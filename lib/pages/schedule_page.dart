
import 'package:flutter/material.dart';
import 'package:dr_drugs/utils/colors.dart';
import 'package:dr_drugs/utils/medication.dart';
import 'package:dr_drugs/widgets/clock_widget.dart';
import 'package:dr_drugs/widgets/medication_pagination.dart';
import 'package:dr_drugs/services/medication_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late Future<List<Medication>> medicationsFuture;

  final Set<String> _updatingDoses = {};

  @override
  void initState() {
    super.initState();
    medicationsFuture = loadMedications();
  }

  String get today {
    final now = DateTime.now();

    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String getDoseKey(Medication medication) {
    return '${medication.id}_${medication.time}';
  }

  
Future<List<Medication>> loadMedications() async {
  // STEP 1: Retrieve medications.
  List<Map<String, dynamic>> records;

  try {
    records = await MedicationService.getMedications();
    debugPrint('SUCCESS: Medications retrieved: ${records.length}');
  } catch (e, stackTrace) {
    debugPrint('MEDICATION API ERROR: $e');
    debugPrintStack(stackTrace: stackTrace);

    throw Exception('Failed to retrieve medications: $e');
  }

  // STEP 2: Retrieve today's tracking records.
  List<Map<String, dynamic>> logs;

  try {
    logs = await MedicationService.getTracking(date: today);
    debugPrint('SUCCESS: Tracking records retrieved: ${logs.length}');
  } catch (e, stackTrace) {
    debugPrint('TRACKING API ERROR: $e');
    debugPrintStack(stackTrace: stackTrace);

    throw Exception('Failed to retrieve tracking records: $e');
  }

  // STEP 3: Build tracking lookup.
  final Map<String, bool> trackingMap = {};

  String normalizeTime(String value) {
    return value.length >= 5 ? value.substring(0, 5) : value;
  }

  for (final log in logs) {
    final medicationId = log['medication_id']?.toString() ?? '';
    final rawTime = log['scheduled_time']?.toString() ?? '';

    final time = normalizeTime(rawTime);
    trackingMap['${medicationId}_$time'] =
        log['is_taken'] == true;
  }

  // STEP 4: Build medication schedule.
  final List<Medication> schedule = [];

  for (final record in records) {
    final String id = record['id']?.toString() ?? '';
    final String name = record['name']?.toString() ?? 'Obat';

    final String bentukObat =
        record['bentuk_obat']?.toString() ?? '';

    final double totalAmount =
        double.tryParse(record['jumlah']?.toString() ?? '') ?? 0;

    final double amountPerDose =
        double.tryParse(record['jumlah_per_minum']?.toString() ?? '') ?? 0;

    final bool isAsNeeded = record['is_as_needed'] == true;

    final String dosage =
        '${formatAmount(amountPerDose)} ${getUnit(bentukObat)}';

    final String instruction =
        '$bentukObat • Total: '
        '${formatAmount(totalAmount)} ${getUnit(bentukObat)}';

    if (isAsNeeded) {
      schedule.add(
        Medication(
          id: id,
          name: name,
          dosage: dosage,
          instruction: instruction,
          time: 'Sesuai kebutuhan',
          isAsNeeded: true,
        ),
      );

      continue;
    }

    final rawTimes = record['times'];

    final List<String> times = rawTimes is List
        ? rawTimes.map((time) => normalizeTime(time.toString())).toList()
        : [];

    for (final time in times) {
      final key = '${id}_$time';

      schedule.add(
        Medication(
          id: id,
          name: name,
          dosage: dosage,
          instruction: instruction,
          time: time,
          isTaken: trackingMap[key] ?? false,
        ),
      );
    }
  }

  // STEP 5: Sort medications.
  schedule.sort((a, b) {
    // As-needed medications always go last.
    if (a.isAsNeeded && !b.isAsNeeded) return 1;
    if (!a.isAsNeeded && b.isAsNeeded) return -1;

    // Already-taken medications go below untaken medications.
    if (a.isTaken && !b.isTaken) return 1;
    if (!a.isTaken && b.isTaken) return -1;

    // Sort remaining medications by scheduled time.
    return a.time.compareTo(b.time);
  });

  debugPrint('FINAL SCHEDULE COUNT: ${schedule.length}');

  return schedule;
}


  String getUnit(String bentukObat) {
    if (bentukObat.toLowerCase().contains('sirup') ||
        bentukObat.toLowerCase().contains('cair')) {
      return 'ml';
    }

    return 'pcs';
  }

  String formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toString();
  }

  Future<void> _toggleMedication(Medication medication) async {
    // PRN medications do not have a fixed scheduled time.
    if (medication.isAsNeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Obat sesuai kebutuhan belum mendukung pelacakan dosis.',
          ),
        ),
      );

      return;
    }

    final doseKey = getDoseKey(medication);

    if (_updatingDoses.contains(doseKey)) return;

    setState(() {
      _updatingDoses.add(doseKey);
    });

    try {
      await MedicationService.updateTracking(
        medicationId: medication.id,
        date: today,
        time: medication.time,
        isTaken: !medication.isTaken,
      );

      if (!mounted) return;

      setState(() {
        medicationsFuture = loadMedications();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            medication.isTaken
                ? 'Status obat diubah menjadi belum diminum.'
                : 'Obat berhasil ditandai sudah diminum!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memperbarui status obat: '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingDoses.remove(doseKey);
        });
      }
    }
  }

  void refreshMedications() {
    setState(() {
      medicationsFuture = loadMedications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                const Text(
                  'Jadwal Obat',
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryFontColor,
                  ),
                ),

                const Text(
                  'Obat Saya',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryFontColor,
                  ),
                ),

                const ClockWidget(),

                const SizedBox(height: 20),

                FutureBuilder<List<Medication>>(
                  future: medicationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 40,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Gagal memuat data obat.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: refreshMedications,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    }

                    final medications = snapshot.data ?? [];

                    if (medications.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Column(
                            children: [
                              Icon(
                                Icons.medication_outlined,
                                size: 50,
                                color: primaryFontColor,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada obat yang ditambahkan.',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return MedicationScrollable(
                      medications: medications,
                      onToggle: _toggleMedication,
                      updatingDoses: _updatingDoses,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

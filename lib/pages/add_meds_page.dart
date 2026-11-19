
import 'package:flutter/material.dart';

import 'package:dr_drugs/utils/colors.dart';
import 'package:dr_drugs/widgets/custom_clock_wheel.dart';
import 'package:dr_drugs/widgets/custom_option_selector.dart';
import 'package:dr_drugs/widgets/frequency_selector.dart';
import 'package:dr_drugs/widgets/text_input.dart';
import 'package:dr_drugs/services/medication_service.dart';

class AddMedsPage extends StatefulWidget {
  const AddMedsPage({super.key});

  @override
  State<AddMedsPage> createState() => _AddMedsPageState();
}

class _AddMedsPageState extends State<AddMedsPage> {
  final PageController pageController = PageController();

  int currentPage = 0;
  final int totalPages = 3;

  // Default medication times
  final List<TimeOfDay> defaultTimes = [
    // const TimeOfDay(hour: 8, minute: 0),
    const TimeOfDay(hour: 12, minute: 30),
    // const TimeOfDay(hour: 20, minute: 0),
  ];

  // Input controllers
  final TextEditingController _medsNameController =
      TextEditingController();

  final TextEditingController _medsAmountController =
      TextEditingController();

  final TextEditingController _medsFrequencyAmountController =
      TextEditingController();

  // Medication form values
  final List<String> bentukObatOptions = [
    'Pil / Tablet',
    'Kapsul',
    'Sirup / Cair',
  ];

  String selectedBentukObat = 'Pil / Tablet';

  bool isAsNeeded = false;
  bool isSaving = false;

  int frequency = 1;

  // Store up to 12 medication times
  late final List<TimeOfDay> medicationTimes = List.generate(
    12,
    (index) => defaultTimes[index % defaultTimes.length],
  );

  @override
  void dispose() {
    pageController.dispose();

    _medsNameController.dispose();
    _medsAmountController.dispose();
    _medsFrequencyAmountController.dispose();

    super.dispose();
  }

  // Convert TimeOfDay to HH:mm
  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // Save medication to Supabase through backend
  Future<void> _saveMedication() async {
    if (isSaving) return;

    final name = _medsNameController.text.trim();

    final jumlah = double.tryParse(
      _medsAmountController.text.trim(),
    );

    final jumlahPerMinum = double.tryParse(
      _medsFrequencyAmountController.text.trim(),
    );

    // Validate form
    if (name.isEmpty ||
        jumlah == null ||
        jumlah <= 0 ||
        jumlahPerMinum == null ||
        jumlahPerMinum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon lengkapi semua data obat dengan benar.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final selectedTimes = isAsNeeded
          ? <String>[]
          : medicationTimes
              .take(frequency)
              .map(formatTime)
              .toList();

      final result = await MedicationService.saveMedication(
        name: name,
        bentukObat: selectedBentukObat,
        jumlah: jumlah,
        jumlahPerMinum: jumlahPerMinum,
        frequency: isAsNeeded ? 0 : frequency,
        isAsNeeded: isAsNeeded,
        times: selectedTimes,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Obat berhasil disimpan!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Keep the form open for now.
      // We can add navigation to the medication list later.

    } catch (error) {
      debugPrint('SAVE MEDICATION ERROR: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  pageOne(),
                  pageTwo(),
                  pageThree(),
                ],
              ),
            ),

            buildPageButtons(),
          ],
        ),
      ),
    );
  }

  // Bottom navigation buttons
  Widget buildPageButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 0, 7, 36),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: currentPage > 0 && !isSaving
                    ? () {
                        setState(() {
                          currentPage--;
                        });

                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tertiaryButtonColor,
                  foregroundColor: secondaryFontColor,
                  textStyle: const TextStyle(fontSize: 20),
                  elevation: 0,
                  iconSize: 18,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_left),
                    SizedBox(width: 4),
                    Text('Sebelumnya'),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () {
                        if (currentPage < totalPages - 1) {
                          setState(() {
                            currentPage++;
                          });

                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _saveMedication();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryButtonColor,
                  foregroundColor: secondaryFontColor,
                  textStyle: const TextStyle(fontSize: 20),
                  iconSize: 18,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentPage == totalPages - 1
                                ? 'Simpan'
                                : 'Selanjutnya',
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_right),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 1: Medication information
  Widget pageOne() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            const Text(
              "Obat Baru",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryFontColor,
              ),
            ),

            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nama Obat",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryFontColor,
                    ),
                  ),

                  PrimaryTextInput(
                    hintText: "Contoh: Aspirin",
                    controller: _medsNameController,
                    keyboardType: TextInputType.text,
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Bentuk Obat",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryFontColor,
                    ),
                  ),

                  CustomOptionSelector(
                    options: bentukObatOptions,
                    selectedOption: selectedBentukObat,
                    onChanged: (value) {
                      setState(() {
                        selectedBentukObat = value;
                      });
                    },
                  ),

                  const SizedBox(height: 33),

                  const Text(
                    "Jumlah Obat",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryFontColor,
                    ),
                  ),

                  const Text(
                    "(dalam pcs/ml)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryFontColor,
                    ),
                  ),

                  PrimaryTextInput(
                    hintText: "Contoh: 20",
                    controller: _medsAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PAGE 2: Dosage and frequency
  Widget pageTwo() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            const Text(
              "Obat Baru",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryFontColor,
              ),
            ),

            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Jumlah per Minum",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryFontColor,
                    ),
                  ),

                  const Text(
                    "(dalam pcs/ml)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryFontColor,
                    ),
                  ),

                  PrimaryTextInput(
                    hintText: "Contoh: 1 (pcs), 40 (ml)",
                    controller: _medsFrequencyAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Berapa Kali Sehari?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryFontColor,
                    ),
                  ),

                  FrequencySelector(
                    isAsNeeded: isAsNeeded,
                    frequency: frequency,
                    onTypeChanged: (value) {
                      setState(() {
                        isAsNeeded = value;
                      });
                    },
                    onFrequencyChanged: (value) {
                      setState(() {
                        frequency = value;
                        isAsNeeded = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PAGE 3: Medication times
  Widget pageThree() {
    final int clockCount = isAsNeeded ? 0 : frequency;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            const Text(
              "Obat Baru",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryFontColor,
              ),
            ),

            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (clockCount == 0)
                    const Text(
                      'Obat diminum hanya sesuai kebutuhan.',
                      style: TextStyle(fontSize: 14),
                    ),

                  ...List.generate(clockCount, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jam Makan Obat ${index + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          CustomClockWheel(
                            key: ValueKey('clock_$index'),
                            initialHour: medicationTimes[index].hour,
                            initialMinute:
                                medicationTimes[index].minute,
                            onChanged: (time) {
                              medicationTimes[index] = time;
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:dr_drugs/utils/colors.dart';
import 'package:dr_drugs/widgets/custom_clock_wheel.dart';
import 'package:dr_drugs/widgets/custom_option_selector.dart';
import 'package:dr_drugs/widgets/frequency_selector.dart';
import 'package:dr_drugs/widgets/text_input.dart';
import 'package:flutter/material.dart';
import 'package:dr_drugs/services/medication_service.dart';
import 'package:dr_drugs/services/auth_service.dart';
import 'package:dr_drugs/pages/main_page.dart';
import 'package:dr_drugs/utils/navigator.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final PageController pageController = PageController();

  int currentPage = 0;
  final int totalPages = 3;
  bool _isSaving = false;

  final List<TimeOfDay> defaultTimes = [
    // const TimeOfDay(hour: 8, minute: 0),
    const TimeOfDay(hour: 12, minute: 30),
    // const TimeOfDay(hour: 19, minute: 0),
  ];

  // INPUT CONTROLLERS
  final TextEditingController _medsNameController =
      TextEditingController();

  final TextEditingController _medsAmountController =
      TextEditingController();

  final TextEditingController _medsFrequencyAmountController =
      TextEditingController();

  final List<String> bentukObatOptions = [
    'Pil / Tablet',
    'Kapsul',
    'Sirup / Cair',
  ];

  String selectedBentukObat = 'Pil / Tablet';

  bool isAsNeeded = false;
  int frequency = 1;

  late final List<TimeOfDay> medicationTimes = List.generate(
    12,
    (index) => defaultTimes[index % defaultTimes.length],
  );

  // SAVE FIRST MEDICATION
  Future<void> _saveInitialMedication() async {
    if (_isSaving) return;

    final name = _medsNameController.text.trim();

    final totalAmount = double.tryParse(
      _medsAmountController.text.trim(),
    );

    final amountPerDose = double.tryParse(
      _medsFrequencyAmountController.text.trim(),
    );

    // VALIDATION
    if (name.isEmpty) {
      _showMessage('Nama obat harus diisi.');
      return;
    }

    if (totalAmount == null || totalAmount <= 0) {
      _showMessage('Masukkan jumlah obat yang valid.');
      return;
    }

    if (amountPerDose == null || amountPerDose <= 0) {
      _showMessage('Masukkan jumlah per minum yang valid.');
      return;
    }

    final int savedFrequency = isAsNeeded ? 0 : frequency;

    final List<String> times = isAsNeeded
        ? []
        : List.generate(frequency, (index) {
            final time = medicationTimes[index];

            return '${time.hour.toString().padLeft(2, '0')}:'
                '${time.minute.toString().padLeft(2, '0')}';
          });

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Save the user's first medication.
      await MedicationService.saveMedication(
        name: name,
        bentukObat: selectedBentukObat,
        jumlah: totalAmount,
        jumlahPerMinum: amountPerDose,
        frequency: savedFrequency,
        isAsNeeded: isAsNeeded,
        times: times,
      );

      // 2. Mark onboarding as completed.
      await AuthService.completeOnboarding();

      if (!mounted) return;

      // 3. Navigate to the main application.
      navigate(context, const MainPage(), false);

    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Gagal menyimpan: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // SHOW MESSAGE
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // DISPOSE CONTROLLERS
  @override
  void dispose() {
    pageController.dispose();
    _medsNameController.dispose();
    _medsAmountController.dispose();
    _medsFrequencyAmountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
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

            const SizedBox(height: 68),
          ],
        ),
      ),
    );
  }

  // PAGE NAVIGATION BUTTONS
  Widget buildPageButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 0, 7, 36),
      child: Row(
        children: [
          // PREVIOUS BUTTON
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: currentPage > 0 && !_isSaving
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
                  textStyle: const TextStyle(
                    fontSize: 20,
                  ),
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

          // NEXT / SAVE BUTTON
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving
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
                          _saveInitialMedication();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryButtonColor,
                  foregroundColor: secondaryFontColor,
                  textStyle: TextStyle(
                    fontSize: _isSaving
                      ? 14
                      : 20,
                  ),
                  iconSize: 18,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSaving
                          ? 'Menyimpan...'
                          : currentPage == totalPages - 1
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

  // PAGE 1: MEDICATION INFORMATION
  Widget pageOne() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20.0),
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
                color: secondaryFontColor,
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
                      color: secondaryFontColor,
                    ),
                  ),

                  SecondaryTextInput(
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
                      color: secondaryFontColor,
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
                    isSecondary: true,
                  ),

                  const SizedBox(height: 33),

                  const Text(
                    "Jumlah Obat",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: secondaryFontColor,
                    ),
                  ),

                  const Text(
                    "(dalam pcs/ml)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: secondaryFontColor,
                    ),
                  ),

                  SecondaryTextInput(
                    hintText: "Contoh: 20",
                    controller: _medsAmountController,
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PAGE 2: DOSAGE AND FREQUENCY
  Widget pageTwo() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20.0),
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
                color: secondaryFontColor,
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
                      color: secondaryFontColor,
                    ),
                  ),

                  const Text(
                    "(dalam pcs/ml)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: secondaryFontColor,
                    ),
                  ),

                  SecondaryTextInput(
                    hintText: "Contoh: 1 (pcs), 40 (ml)",
                    controller: _medsFrequencyAmountController,
                    keyboardType: TextInputType.text,
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Berapa Kali Sehari?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: secondaryFontColor,
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
                    isSecondary: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PAGE 3: MEDICATION SCHEDULE
  Widget pageThree() {
    final int clockCount = isAsNeeded ? 0 : frequency;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20.0),
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
                color: secondaryFontColor,
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
                              color: secondaryFontColor,
                            ),
                          ),

                          const SizedBox(height: 6),

                          CustomClockWheel(
                            key: ValueKey('clock_$index'),
                            initialHour: medicationTimes[index].hour,
                            initialMinute: medicationTimes[index].minute,
                            onChanged: (time) {
                              medicationTimes[index] = time;
                            },
                            isSecondary: true,
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

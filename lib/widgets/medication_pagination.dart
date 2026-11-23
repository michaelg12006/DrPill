
import 'package:flutter/material.dart';
import 'package:dr_drugs/utils/medication.dart';
import 'package:dr_drugs/widgets/medication_card.dart';

class MedicationScrollable extends StatelessWidget {
  final List<Medication> medications;
  final Function(Medication) onToggle;
  final Set<String> updatingDoses;

  const MedicationScrollable({
    super.key,
    required this.medications,
    required this.onToggle,
    this.updatingDoses = const {},
  });

  String getDoseKey(Medication medication) {
    return '${medication.id}_${medication.time}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 375,
          child: Stack(
            children: [
              ListView.builder(
                itemCount: medications.length,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16.0),
                itemBuilder: (context, index) {
                  final medication = medications[index];
                  final doseKey = getDoseKey(medication);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: MedicationCard(
                      medication: medication,
                      isUpdating: updatingDoses.contains(doseKey),
                      onToggle: () => onToggle(medication),
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 65,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00F2FCEB),
                          Color(0xFFF2FCEB),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

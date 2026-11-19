
import 'package:dr_drugs/utils/colors.dart';
import 'package:dr_drugs/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:dr_drugs/utils/medication.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onToggle;
  final bool isUpdating;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onToggle,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.medication_outlined,
                size: 32,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '${medication.dosage} • '
                      '${medication.instruction} • '
                      '${medication.time}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: isUpdating
                ? 'Memproses...'
                : medication.isTaken
                    ? 'Sudah Diminum'
                    : 'Tandai Sudah Diminum',
            onTap: isUpdating ? () {} : onToggle,
            buttonColor: medication.isTaken
                ? disabledButtonColor
                : primaryButtonColor,
            textColor: secondaryFontColor,
          ),
        ],
      ),
    );
  }
}

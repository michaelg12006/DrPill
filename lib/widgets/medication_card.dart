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

  // CHANGE NEEDED: icon change accordingly
  IconData getIcon() {
    if (medication.instruction.contains('Pil / Tablet')) {
      return Icons.medication;
    } else if (medication.instruction.contains('Kapsul')) {
      return Icons.medication;
    } else if (medication.instruction.contains('Sirup / Cair')) {
      return Icons.water_drop_outlined;
    } else {
      return Icons.medication;
    }
  }

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
              Container(
                height: 80,
                width: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(getIcon(), color: primaryDarkColor, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: primaryDarkColor
                      ),
                    ),
                    Text(
                      '${medication.dosage} • '
                      '${medication.time}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    Divider(
                      color: primaryDarkColor.withOpacity(0.5),
                    ),
                    Text(
                      medication.instruction,
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

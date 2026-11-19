import 'package:dr_drugs/utils/colors.dart';
import 'package:flutter/material.dart';
import 'custom_number_wheel.dart';

class FrequencySelector extends StatelessWidget {
  final bool isAsNeeded;
  final int frequency;
  final ValueChanged<bool> onTypeChanged;
  final ValueChanged<int> onFrequencyChanged;
  final bool isSecondary;

  const FrequencySelector({
    super.key,
    required this.isAsNeeded,
    required this.frequency,
    required this.onTypeChanged,
    required this.onFrequencyChanged,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onTypeChanged(false),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: !isAsNeeded
                      ? isSecondary
                          ? secondaryTextFieldColor
                          : primaryTextFieldColor
                      : primaryCardColor,
                  border: Border.all(
                    color: !isAsNeeded
                        ? isSecondary
                            ? secondaryTextFieldBorderColor 
                            : primaryTextFieldBorderColor
                        : primaryCardBorderColor,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              CustomNumberWheel(
                isAsNeeded: isAsNeeded,
                selectedValue: frequency,
                onChanged: onFrequencyChanged,
                minValue: 1,
                maxValue: 12,
                isSecondary: isSecondary,
              ),

              const SizedBox(width: 8),

              Text(
                'kali sehari',
                style: TextStyle(
                  fontSize: 16, 
                  color: isSecondary
                    ? secondaryFontColor
                    : primaryFontColor
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: () => onTypeChanged(true),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isAsNeeded
                      ? isSecondary
                          ? secondaryTextFieldColor
                          : primaryTextFieldColor
                      : primaryCardColor,
                  border: Border.all(
                    color: isAsNeeded
                        ? isSecondary
                            ? secondaryTextFieldBorderColor 
                            : primaryTextFieldBorderColor
                        : primaryCardBorderColor,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isAsNeeded
                    ? isSecondary
                          ? secondaryTextFieldColor
                          : primaryTextFieldColor
                    : primaryCardColor,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: isAsNeeded
                      ? isSecondary
                            ? secondaryTextFieldBorderColor 
                            : primaryTextFieldBorderColor
                      : primaryCardBorderColor,
                  ),
                ),
                child: const Text(
                  'Hanya Seperlunya',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
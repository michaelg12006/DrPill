import 'package:dr_drugs/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomOptionSelector extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onChanged;
  final bool isSecondary;

  const CustomOptionSelector({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        ...options.map((option) {
          final isSelected = selectedOption == option;

          return GestureDetector(
            onTap: () => onChanged(option),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                        ? isSecondary
                          ? secondaryTextFieldColor
                          : primaryTextFieldColor
                        : primaryCardColor,
                      border: Border.all(
                        color: isSelected
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
                      color: isSelected
                        ? isSecondary
                          ? secondaryTextFieldColor
                          : primaryTextFieldColor
                        : primaryCardColor,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: isSelected
                          ? isSecondary
                            ? secondaryTextFieldBorderColor 
                            : primaryTextFieldBorderColor
                          : primaryCardBorderColor,
                      ),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
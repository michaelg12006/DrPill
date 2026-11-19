import 'package:dr_drugs/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomNumberWheel extends StatelessWidget {
  final bool isAsNeeded;
  final int selectedValue;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;
  final bool isSecondary;

  const CustomNumberWheel({
    super.key,
    required this.isAsNeeded,
    required this.selectedValue,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 6,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      height: 100,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 45,
        perspective: 0.003,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(
          initialItem: selectedValue - minValue,
        ),
        onSelectedItemChanged: (index) {
          onChanged(index + minValue);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: maxValue - minValue + 1,
          builder: (context, index) {
            final value = index + minValue;
            final isSelected = value == selectedValue;

            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected && !isAsNeeded
                    ? isSecondary
                      ? secondaryTextFieldColor
                      : primaryTextFieldColor
                    : primaryCardColor,
                // : Colors.transparent,
                border: Border.all(
                  color: isSelected && !isAsNeeded
                      ? isSecondary
                        ? secondaryTextFieldBorderColor 
                        : primaryTextFieldBorderColor
                      : primaryCardBorderColor,
                  // : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: isSelected ? 18 : 15,
                  color: primaryFontColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

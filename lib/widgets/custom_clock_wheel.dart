
import 'package:dr_drugs/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomClockWheel extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final ValueChanged<TimeOfDay> onChanged;
  final bool isSecondary;

  const CustomClockWheel({
    super.key,
    required this.initialHour,
    required this.initialMinute,
    required this.onChanged,
    this.isSecondary = false,
  });

  @override
  State<CustomClockWheel> createState() =>
      _CustomClockWheelState();
}

class _CustomClockWheelState extends State<CustomClockWheel> {
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  late int selectedHour;
  late int selectedMinute;

  late bool isSecondary;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialHour;
    selectedMinute = widget.initialMinute;
    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    isSecondary = widget.isSecondary;
  }

  void updateTime() {
    widget.onChanged(
      TimeOfDay(
        hour: selectedHour,
        minute: selectedMinute,
      ),
    );
  }

  Widget buildWheel({
    required FixedExtentScrollController controller,
    required int maxValue,
    required int selectedValue,
    required ValueChanged<int> onSelected,
  }) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 30,
        diameterRatio: 1.5,
        perspective: 0.003,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelected,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: maxValue,
          builder: (context, index) {
            final isSelected = index == selectedValue;

            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? primaryFontColor
                      : primaryFontColor.withOpacity(0.2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 144,
      decoration: BoxDecoration(
        color: secondaryAltTextFieldColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: secondaryTextFieldBorderColor,
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 40,
            color: isSecondary
              ? tertiaryButtonColor
              : primaryColor,
            child: const Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Jam',
                      style: TextStyle(
                        color: secondaryFontColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Center(
                    child: Text(
                      ':',
                      style: TextStyle(
                        color: secondaryFontColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Menit',
                      style: TextStyle(
                        color: secondaryFontColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                buildWheel(
                  controller: hourController,
                  maxValue: 24,
                  selectedValue: selectedHour,
                  onSelected: (value) {
                    setState(() {
                      selectedHour = value;
                    });
                    updateTime();
                  },
                ),

                const SizedBox(
                  width: 20,
                  child: Center(
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                buildWheel(
                  controller: minuteController,
                  maxValue: 60,
                  selectedValue: selectedMinute,
                  onSelected: (value) {
                    setState(() {
                      selectedMinute = value;
                    });
                    updateTime();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

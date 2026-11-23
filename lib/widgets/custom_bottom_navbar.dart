import 'package:dr_drugs/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final List<IconData> icons = const [
    Icons.notifications_none_outlined,
    Icons.medical_services_outlined,
    Icons.support_agent_outlined,
  ];

  final List<String> labels = const [
    'Cek Obat',
    'Tambah Obat',
    'Kontak',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      color: primaryColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 3;

          return Stack(
            children: [
              // Animated selection indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                left: itemWidth * currentIndex + 4,
                top: 5,
                bottom: 5,
                width: itemWidth - 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: secondaryButtonColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              Row(
                children: List.generate(3, (index) {
                  final isSelected = currentIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        height: 68,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: isSelected ? 1.12 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              child: Icon(
                                icons[index],
                                color: secondaryColor,
                                size: 28,
                              ),
                            ),

                            const SizedBox(height: 3),

                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              child: Text(labels[index]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
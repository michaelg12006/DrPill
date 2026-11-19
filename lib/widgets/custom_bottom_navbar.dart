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
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? secondaryButtonColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icons[index],
                      color: secondaryColor,
                      size: 28,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      labels[index],
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
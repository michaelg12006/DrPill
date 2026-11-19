
import 'package:dr_drugs/utils/colors.dart';
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final VoidCallback? onTap;

  const ContactCard({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: primaryCardColor,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Contact Icon
            const Icon(
              Icons.person_outline,
              size: 40,
              color: Color(0xFF34495E),
            ),

            const SizedBox(width: 12),

            // Name and Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryFontColor,
                    ),
                  ),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: primaryFontColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Time
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

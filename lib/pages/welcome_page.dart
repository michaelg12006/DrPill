import 'package:dr_drugs/pages/login_page.dart';
import 'package:dr_drugs/utils/colors.dart';
import 'package:dr_drugs/utils/navigator.dart';
import 'package:dr_drugs/widgets/custom_button.dart';
import 'package:dr_drugs/widgets/medical_painter_pattern.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: MedicalPatternPainter())),

                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),

                          Container(
                            height: 200,
                            width: 200,
                            decoration: const BoxDecoration(
                              color: iconBackgroundGreen,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Image.asset(
                              'images/logo_textbelow.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Never miss a dose.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),

                          const Text(
                            'Family always in the loop.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Pengingat minum obat yang ramah bagi lansia, '
                            'dengan pembaruan instan melalui WhatsApp untuk keluarga tercinta.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              height: 1.5,
                              color: fontDarkGreen,
                            ),
                          ),

                          const SizedBox(height: 28),

                          _buildFeature(
                            Icons.accessibility_new,
                            'Elderly-Friendly UI',
                            'Tampilan sederhana, tulisan jelas, '
                                'dan mudah digunakan.',
                          ),

                          const SizedBox(height: 22),

                          _buildFeature(
                            Icons.chat,
                            'WhatsApp Family Alerts',
                            'Keluarga dapat menerima informasi '
                                'terkait jadwal obat Anda.',
                          ),

                          const SizedBox(height: 22),

                          _buildFeature(
                            Icons.handshake,
                            'Easy Setup',
                            'Mudah diatur tanpa proses yang rumit.',
                          ),

                          const SizedBox(height: 32),

                          KeyedSubtree(
                            key: _buttonKey,
                            child: CustomButton(
                              text: 'Mulai Sekarang',
                              onTap: () {
                                final buttonBox = _buttonKey.currentContext!
                                    .findRenderObject() as RenderBox;

                                final overlayBox = Navigator.of(context)
                                    .overlay!
                                    .context
                                    .findRenderObject() as RenderBox;

                                // Get the center of the button in global coordinates.
                                final buttonCenter = buttonBox.localToGlobal(
                                  buttonBox.size.center(Offset.zero),
                                );

                                // Convert global coordinates into Navigator overlay coordinates.
                                final origin = overlayBox.globalToLocal(buttonCenter);

                                navigate(
                                  context,
                                  const LoginPage(),
                                  true,
                                  isCircularTransition: true,
                                  origin: origin,
                                );
                              },
                              buttonColor: primaryButtonColor,
                              textColor: secondaryFontColor,
                              isBold: true,
                            ),
                          ),
                          
                          // SizedBox(
                          //   width: double.infinity,
                          //   height: 58,
                          //   child: ElevatedButton(
                          //     onPressed: () {
                          //       navigate(context, LoginPage(), false);
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: primaryGreen,
                          //       foregroundColor: Colors.white,
                          //       elevation: 0,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(14),
                          //       ),
                          //     ),
                          //     child: const Text(
                          //       'Mulai Sekarang',
                          //       style: TextStyle(
                          //         fontSize: 19,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          // const SizedBox(height: 18),

                          // const Text(
                          //   'Never miss a dose. Family always in the loop.',
                          //   style: TextStyle(fontSize: 14, color: darkGreen),
                          // ),

                          // const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            )
          );
        }
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: iconBackgroundGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: primaryDarkColor, size: 29),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: primaryDarkColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: fontDarkGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
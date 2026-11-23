
import 'package:dr_drugs/widgets/medical_painter_pattern.dart';
import 'package:flutter/material.dart';
import 'package:dr_drugs/utils/colors.dart';
import 'package:dr_drugs/utils/navigator.dart';
import 'package:dr_drugs/widgets/custom_button.dart';
import 'package:dr_drugs/widgets/text_input.dart';
import 'package:dr_drugs/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Semua kolom harus diisi.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Konfirmasi kata sandi tidak cocok.');
      return;
    }

    if (password.length < 8) {
      _showMessage('Kata sandi minimal 8 karakter.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage(
        'Pendaftaran berhasil! Silakan masuk menggunakan akun Anda.',
      );

      navigateBack(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: MedicalPatternPainter(isSecondary: true))),
                  
                  SafeArea(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),
                            const Text(
                              "Daftar",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: secondaryFontColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(30),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Nama",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: secondaryFontColor,
                                    ),
                                  ),
                                  SecondaryTextInput(
                                    hintText: "",
                                    controller: _nameController,
                                    keyboardType: TextInputType.text,
                                  ),
                                  const SizedBox(height: 40),
                                  const Text(
                                    "Email",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: secondaryFontColor,
                                    ),
                                  ),
                                  SecondaryTextInput(
                                    hintText: "",
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 40),
                                  const Text(
                                    "Kata Sandi",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: secondaryFontColor,
                                    ),
                                  ),
                                  SecondaryTextInput(
                                    hintText: "",
                                    controller: _passwordController,
                                    keyboardType: TextInputType.text,
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 40),
                                  const Text(
                                    "Konfirmasi Kata Sandi",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: secondaryFontColor,
                                    ),
                                  ),
                                  SecondaryTextInput(
                                    hintText: "",
                                    controller: _confirmController,
                                    keyboardType: TextInputType.text,
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 40),
                                  CustomButton(
                                    text: _isLoading ? "Memproses..." : "Daftar",
                                    onTap: _isLoading ? () {} : _handleRegister,
                                    buttonColor: secondaryButtonColor,
                                    textColor: secondaryFontColor,
                                  ),
                                  const SizedBox(height: 15),
                                  CustomButton(
                                    text: "Sudah Punya Akun?",
                                    onTap: () {
                                      navigateBack(context);
                                    },
                                    buttonColor: tertiaryButtonColor,
                                    textColor: secondaryFontColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]
              )
            )
          );
        }
      )
    );
  }
}

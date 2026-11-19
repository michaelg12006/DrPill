
import 'package:dr_drugs/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:dr_drugs/utils/colors.dart';
import 'package:dr_drugs/utils/navigator.dart';
import 'package:dr_drugs/widgets/custom_button.dart';
import 'package:dr_drugs/widgets/text_input.dart';
import 'package:dr_drugs/pages/register_page.dart';
import 'package:dr_drugs/services/auth_service.dart';
import 'package:dr_drugs/pages/initial_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan kata sandi harus diisi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final loginData = await AuthService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      final user = loginData['user'];

      final metadata = user is Map
          ? user['user_metadata']
          : null;

      final onboardingCompleted =
          metadata is Map &&
          metadata['onboarding_completed'] == true;

      if (onboardingCompleted) {
        navigate(context, const MainPage(), false);
      } else {
        navigate(context, const InitialPage(), false);
      }

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Text(
                  "Masuk",
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
                      CustomButton(
                        text: _isLoading ? "Memproses..." : "Masuk",
                        onTap: _isLoading ? () {} : _handleLogin,
                        buttonColor: secondaryButtonColor,
                        textColor: secondaryFontColor,
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                        text: "Buat Akun",
                        onTap: () {
                          navigate(context, const RegisterPage(), true);
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
    );
  }
}

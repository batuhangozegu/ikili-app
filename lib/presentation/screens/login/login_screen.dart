import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/presentation/screens/widgets/auth_mode_toggle.dart';
import 'package:ikili_app/presentation/widgets/labeled_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoginMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BIR HESAP, İKİ KİŞİ', style: AppTheme.eyebrow),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        style: AppTheme.heading,
                        children: [
                          const TextSpan(text: 'İkili'),
                          TextSpan(
                            text: ".",
                            style: TextStyle(color: AppTheme.accent),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sorularını sen yaz, tahmini o yapsın. Sonuç ikinizi de şaşırtacak.',
                      style: AppTheme.body,
                    ),

                    const SizedBox(height: 32),

                    AuthModeToggle(
                      isLoginMode: _isLoginMode, 
                      onModeChanged: (value) => setState(() => _isLoginMode = value)
                      ),

                    const SizedBox(height: 16),

                    LabeledTextField(
                      label: 'E-posta', 
                      hint: "sen@ornek.com", 
                      controller: _emailController
                      ),

                    const SizedBox(height: 16),

                    LabeledTextField(
                      label: 'Şifre', 
                      hint: 'En az 8 karakter', 
                      controller: _passwordController,
                      obscureText: true,
                      ),

                    if (!_isLoginMode) ...[
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Şifre Tekrar',
                        hint: 'Şifreni tekrar gir',
                        controller: _confirmPasswordController, 
                        obscureText: true)
                    ],

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_isLoginMode ? 'Giriş Yap' : 'Hesap Oluştur'),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          side: const BorderSide(color: AppTheme.accent),
                          foregroundColor: AppTheme.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Misafir Olarak Devam Et'),
                      ),
                    ),
                  ],
                ), // Column
              ), // Padding
            ), // IntrinsicHeight
          ), // ConstrainedBox
        ), // SingleChildScrollView
      ), // SafeArea
    ); // Scaffold
  } // build
}

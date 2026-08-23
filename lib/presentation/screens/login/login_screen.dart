import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/presentation/screens/login/widgets/auth_mode_toggle.dart';
import 'package:ikili_app/presentation/viewmodels/auth_view_model.dart';
import 'package:ikili_app/presentation/widgets/ikili_logo.dart';
import 'package:ikili_app/presentation/widgets/labeled_text_field.dart';
import 'package:ikili_app/presentation/widgets/primary_action_button.dart';
import 'package:ikili_app/presentation/widgets/secondary_action_button.dart';
import 'package:provider/provider.dart';

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
  String? _localError;

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final displayError = _localError ?? authViewModel.errorMessage;

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
                    const IkiliLogo(),

                    const SizedBox(height: 8),

                    Text(
                      'Sorularını sen yaz, tahmini o yapsın. Sonuç ikinizi de şaşırtacak.',
                      style: AppTheme.body,
                    ),

                    const SizedBox(height: 32),

                    AuthModeToggle(
                      isLoginMode: _isLoginMode,
                      onModeChanged: (value) {
                        setState(() {
                          _isLoginMode = value;
                          _localError = null; // mod değişince eski hatayı temizle
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    LabeledTextField(
                      label: 'E-posta',
                      hint: "sen@ornek.com",
                      controller: _emailController,
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
                        obscureText: true,
                      ),
                    ],

                    if (displayError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        displayError,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],

                    const Spacer(),

                    PrimaryActionButton(
                      title: _isLoginMode ? 'Giriş Yap' : 'Hesap Oluştur',
                      isLoading: authViewModel.isLoading,
                      onPressed: () async {
                        setState(() => _localError = null);

                        if (_isLoginMode) {
                          await context.read<AuthViewModel>().signIn(
                            _emailController.text,
                            _passwordController.text,
                          );
                        } else {
                          if (_passwordController.text !=
                              _confirmPasswordController.text) {
                            setState(() {
                              _localError = 'Şifreler eşleşmiyor';
                            });
                            return;
                          }
                          await context.read<AuthViewModel>().signUp(
                            _emailController.text,
                            _passwordController.text,
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    SecondaryActionButton(
                      label: 'Misafir Olarak Devam Et',
                      isLoading: authViewModel.isLoading,
                      onPressed: () async {
                        await context.read<AuthViewModel>().signInAnonymously();
                      },
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

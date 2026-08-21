import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';

class AuthModeToggle extends StatelessWidget {
  final bool isLoginMode;
  final ValueChanged<bool> onModeChanged;

  const AuthModeToggle({
    super.key,
    required this.isLoginMode,
    required this.onModeChanged,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => onModeChanged(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isLoginMode
                                      ? AppTheme.accent
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Giriş Yap',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isLoginMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => onModeChanged(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: !isLoginMode
                                      ? AppTheme.accent
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Kayıt Ol',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: !isLoginMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
  }
}
import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';

/// Login ve Home ekranlarında tekrar eden, tam genişlikte, accent renkli
/// kenarlıklı ikincil aksiyon butonu (ör. "Misafir Olarak Devam Et",
/// "Odaya Katıl").
class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          side: const BorderSide(color: AppTheme.accent),
          foregroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label),
      ),
    );
  }
}

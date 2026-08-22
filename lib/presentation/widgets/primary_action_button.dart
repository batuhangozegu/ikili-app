import 'package:flutter/material.dart';

/// Login ve Home ekranlarında tekrar eden, tam genişlikte, accent renkli
/// birincil aksiyon butonu. Tek satır başlık ile (Giriş Yap / Hesap Oluştur)
/// ya da başlık + alt başlık ile (Oda oluştur / Sen soruyorsun) kullanılabilir.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.arrow_forward,
    this.onPressed,
    this.isLoading = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  subtitle == null
                      ? Text(title)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                  if (icon != null) Icon(icon),
                ],
              ),
      ),
    );
  }
}

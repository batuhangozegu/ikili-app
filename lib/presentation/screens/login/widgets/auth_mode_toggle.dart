import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';

/// Login ekranına özel "Giriş Yap / Kayıt Ol" segmentli seçim widget'ı.
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Giriş Yap',
              isSelected: isLoginMode,
              onTap: () => onModeChanged(true),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: 'Kayıt Ol',
              isSelected: !isLoginMode,
              onTap: () => onModeChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

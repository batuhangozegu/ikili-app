import 'package:flutter/material.dart';

/// [PrimaryActionButton] ve [SecondaryActionButton]'da tekrar eden, buton
/// içi küçük yüklenme göstergesi.
class ButtonLoadingIndicator extends StatelessWidget {
  const ButtonLoadingIndicator({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(color: color, strokeWidth: 2),
    );
  }
}

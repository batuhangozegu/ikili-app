import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';

/// "İkili." marka logosu: başlık stilinde marka adı + vurgu renkli nokta.
/// Login ve Home ekranlarında tekrar eden logo bloğunun ortak hali.
class IkiliLogo extends StatelessWidget {
  const IkiliLogo({super.key, this.style});

  /// Verilmezse [AppTheme.heading] kullanılır.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    // RichText, tema/DefaultTextStyle rengini miras almaz; bu yüzden
    // açık temada "İkili" yazısı okunaksız kalıyordu. Text.rich kullanarak
    // ortam metin rengini (açık/koyu temaya göre) doğru şekilde alıyoruz.
    return Text.rich(
      TextSpan(
        style: style ?? AppTheme.heading,
        children: [
          const TextSpan(text: 'İkili'),
          const TextSpan(text: '.', style: TextStyle(color: AppTheme.accent)),
        ],
      ),
    );
  }
}

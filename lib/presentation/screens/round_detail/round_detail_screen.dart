import 'package:flutter/material.dart';

class RoundDetailScreen extends StatelessWidget {
  const RoundDetailScreen({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'Tur Detayı')),
      body: const Center(child: Text('Yakında')),
    );
  }
}

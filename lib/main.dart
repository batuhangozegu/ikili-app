import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ikili_app/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "İkili App",
      home: Scaffold(
        body: Center(child: Text("Firebase bağlandı mı?"),),
      ),
    );
  }
}
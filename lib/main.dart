import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/firebase_options.dart';
import 'package:ikili_app/presentation/screens/home/home_screen.dart';
import 'package:ikili_app/presentation/screens/login/login_screen.dart';
import 'package:ikili_app/presentation/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        title: "İkili App",
        home: const LoginScreen(),
      ),
    );
  }
}
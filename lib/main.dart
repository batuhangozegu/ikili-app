import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/firebase_options.dart';
import 'package:ikili_app/presentation/screens/login/login_screen.dart';
import 'package:ikili_app/presentation/screens/main_navigation/main_navigation_screen.dart';
import 'package:ikili_app/presentation/viewmodels/auth_view_model.dart';
import 'package:ikili_app/presentation/viewmodels/room_view_model.dart';
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
    return MultiProvider(
    providers:[ 
    ChangeNotifierProvider(create: (context) => AuthViewModel()),
    ChangeNotifierProvider(create: (context) => RoomViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        title: "İkili App",
        home: const AuthGate(),
      ),
    );
  }
}

/// Firebase oturum durumuna göre Login ya da ana ekranı gösterir.
/// Giriş/kayıt/misafir girişi başarılı olduğunda [AuthViewModel] bunu
/// otomatik yakalar ve burası kendiliğinden Home'a geçer; ekstra bir
/// Navigator çağrısına gerek yoktur.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return authViewModel.currentUser == null
        ? const LoginScreen()
        : const MainNavigationScreen();
  }
}
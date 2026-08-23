import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/presentation/screens/history/history_screen.dart';
import 'package:ikili_app/presentation/screens/home/home_screen.dart';
import 'package:ikili_app/presentation/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppTheme.accent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset_outlined),
            label: 'Oyna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Geçmiş',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Profil sekmesi; şimdilik sadece oturumu kapatma imkanı sunar.
/// AuthGate, AuthViewModel'deki currentUser null olunca otomatik olarak
/// Login ekranına döner.
class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthViewModel>().currentUser?.email;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(email ?? 'Misafir kullanıcı', style: AppTheme.body),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.read<AuthViewModel>().signOut(),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}

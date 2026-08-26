import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/data/models/app_user_model.dart';
import 'package:ikili_app/data/repositories/user_repository.dart';
import 'package:ikili_app/presentation/viewmodels/auth_view_model.dart';
import 'package:ikili_app/presentation/widgets/secondary_action_button.dart';
import 'package:provider/provider.dart';

/// Profil sekmesi: kullanıcı bilgisi + çıkış yap.
/// AuthGate, AuthViewModel'deki currentUser null olunca otomatik olarak
/// Login ekranına döner, burada ekstra bir navigasyon gerekmez.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userRepository = UserRepository();

  Future<void> _editDisplayName(String uid, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İsmini Güncelle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Görünen isim'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await _userRepository.updateDisplayName(uid, newName);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final uid = user?.uid;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profil', style: AppTheme.heading.copyWith(fontSize: 24)),
            const SizedBox(height: 32),

            if (uid == null)
              const Spacer()
            else
              Expanded(
                child: FutureBuilder<AppUser?>(
                  future: _userRepository.fetchUser(uid),
                  builder: (context, snapshot) {
                    final displayName =
                        snapshot.data?.displayName ?? (user?.isAnonymous ?? true ? 'Misafir' : '');
                    final isGuest = snapshot.data?.isGuest ?? (user?.isAnonymous ?? true);
                    final initial =
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.accent,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!isGuest) ...[
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () =>
                                      _editDisplayName(uid, displayName),
                                ),
                              ],
                            ],
                          ),
                          if (isGuest) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Misafir hesapların geçmişi cihaz değişince kaybolur',
                              style: AppTheme.body,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

            SecondaryActionButton(
              label: 'Çıkış Yap',
              onPressed: () => context.read<AuthViewModel>().signOut(),
            ),
          ],
        ),
      ),
    );
  }
}

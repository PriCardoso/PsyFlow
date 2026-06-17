import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {

  final supabase = Supabase.instance.client;

  User? get user => supabase.auth.currentUser;

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [

          const CircleAvatar(
            radius: 45,
            child: Icon(Icons.person),
          ),

          const SizedBox(height: 24),

          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text(
              'Alterar senha',
            ),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              'Sair',
            ),
            onTap: logout,
          ),
        ],
      ),
    );
  }
}
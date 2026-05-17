import 'package:flutter/material.dart';
import 'privacy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Settings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text('Account',
                  style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
            ),
            _settingsTile(context, Icons.lock_outline, 'Privacy', 'Control who sees your content', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyScreen()));
            }),
            _settingsTile(context, Icons.notifications_outlined, 'Notifications', 'Manage your alerts', () {}),
            _settingsTile(context, Icons.security_outlined, 'Security', 'Password and login', () {}),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text('Content',
                  style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
            ),
            _settingsTile(context, Icons.block_outlined, 'Blocked Accounts', 'Manage blocked users', () {}),
            _settingsTile(context, Icons.filter_alt_outlined, 'Content Filters', 'Filter what you see', () {}),
            _settingsTile(context, Icons.language_outlined, 'Language', 'English', () {}),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text('Support',
                  style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
            ),
            _settingsTile(context, Icons.help_outline, 'Help Center', 'Get support', () {}),
            _settingsTile(context, Icons.info_outline, 'About Era', 'Version 1.0.0', () {}),
            _settingsTile(context, Icons.description_outlined, 'Terms of Service', '', () {}),
            _settingsTile(context, Icons.privacy_tip_outlined, 'Privacy Policy', '', () {}),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Text('Log Out',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFC9A84C), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(color: Colors.white, fontSize: 15)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
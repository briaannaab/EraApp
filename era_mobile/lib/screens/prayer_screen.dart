import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// Words that are not allowed in prayer posts
const List<String> _blockedWords = [
  'hate', 'kill', 'die', 'stupid', 'idiot', 'dumb', 'ugly', 'worthless',
  'loser', 'trash', 'horrible', 'worst', 'terrible', 'disgusting', 'freak',
  'cursed', 'damn', 'hell', 'evil', 'destroy', 'suffer', 'painful', 'hurt',
];

bool _containsNegativeContent(String text) {
  final lower = text.toLowerCase();
  return _blockedWords.any((word) => lower.contains(word));
}

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final prayerController = TextEditingController();
  String _category = 'healing';
  bool _processing = false;
  bool _anonymous = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> categories = [
    {'label': 'Healing', 'emoji': '🌿', 'color': const Color(0xFF4ECDC4)},
    {'label': 'Strength', 'emoji': '💪', 'color': const Color(0xFFFFFFFF)},
    {'label': 'Peace', 'emoji': '🕊️', 'color': const Color(0xFF8B9FFF)},
    {'label': 'Gratitude', 'emoji': '🙏', 'color': const Color(0xFFFF6B35)},
    {'label': 'Guidance', 'emoji': '✨', 'color': const Color(0xFFC084FC)},
    {'label': 'Protection', 'emoji': '🛡️', 'color': const Color(0xFF6BCB77)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A2A), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios, color: Color(0xFFC084FC), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('🙏  Prayer Request',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(52, 4, 20, 0),
                child: Text(
                  'Share your heart. This is a safe, positive space.',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category selector
                      const Text('Category',
                          style: TextStyle(color: Colors.white54, fontSize: 13)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: categories.map((cat) {
                          final isSelected = _category == cat['label'].toString().toLowerCase();
                          return GestureDetector(
                            onTap: () => setState(() => _category = cat['label'].toString().toLowerCase()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (cat['color'] as Color).withOpacity(0.2)
                                    : const Color(0xFF0A0A0A),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? cat['color'] as Color
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(cat['emoji'] as String,
                                      style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(cat['label'] as String,
                                      style: TextStyle(
                                          color: isSelected
                                              ? cat['color'] as Color
                                              : Colors.white54,
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Prayer text
                      const Text('Your Prayer',
                          style: TextStyle(color: Colors.white54, fontSize: 13)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: prayerController,
                        style: const TextStyle(color: Colors.white, height: 1.5),
                        maxLines: 6,
                        maxLength: 500,
                        onChanged: (_) => setState(() => _errorMessage = null),
                        decoration: InputDecoration(
                          hintText: 'Share your prayer request with the community...',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFF0A0A0A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          counterStyle: const TextStyle(color: Colors.white38),
                          errorText: _errorMessage,
                          errorStyle: const TextStyle(color: Colors.red),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Anonymous toggle
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, color: Color(0xFFC084FC), size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Post Anonymously',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('Your name won\'t be shown',
                                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                            ),
                            Switch(
                              value: _anonymous,
                              onChanged: (val) => setState(() => _anonymous = val),
                              activeColor: const Color(0xFFC084FC),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Safe space notice
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6BCB77).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF6BCB77).withOpacity(0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield_outlined, color: Color(0xFF6BCB77), size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Era\'s Prayer Space is moderated. Negative, harmful, or hateful content will not be posted.',
                                style: TextStyle(color: Color(0xFF6BCB77), fontSize: 11, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC084FC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _processing
                              ? null
                              : () async {
                                  if (prayerController.text.isEmpty) return;

                                  if (_containsNegativeContent(prayerController.text)) {
                                    setState(() => _errorMessage =
                                        'Please keep prayers positive and uplifting 🙏');
                                    return;
                                  }

                                  setState(() => _processing = true);
                                  final username = _anonymous ? 'Anonymous' : AuthService.username ?? 'briaannaab';
                                  final content = '🙏 $_category prayer\n\n${prayerController.text}';

                                  await ApiService.createPost(
                                    userId: AuthService.userId ?? 1,
                                    username: username,
                                    content: content,
                                    vibe: 'grounded',
                                  );
                                  setState(() => _processing = false);
                                  if (mounted) Navigator.pop(context);
                                },
                          child: _processing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Send Prayer 🙏',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
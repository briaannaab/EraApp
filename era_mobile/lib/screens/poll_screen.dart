import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PollScreen extends StatefulWidget {
  const PollScreen({super.key});

  @override
  State<PollScreen> createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  final questionController = TextEditingController();
  final List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _processing = false;

  void _addOption() {
    if (optionControllers.length < 4) {
      setState(() => optionControllers.add(TextEditingController()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Create Poll',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ask a question',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: questionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Options',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 8),
            ...optionControllers.asMap().entries.map((entry) {
              final i = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Option ${i + 1}',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF0A0A0A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    if (i >= 2)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white38),
                        onPressed: () =>
                            setState(() => optionControllers.removeAt(i)),
                      ),
                  ],
                ),
              );
            }),
            if (optionControllers.length < 4)
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add, color: Color(0xFF00C9A7)),
                label: const Text('Add option',
                    style: TextStyle(color: Color(0xFF00C9A7))),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C9A7),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _processing
                    ? null
                    : () async {
                        if (questionController.text.isEmpty) return;
                        final options = optionControllers
                            .map((c) => c.text)
                            .where((t) => t.isNotEmpty)
                            .toList();
                        if (options.length < 2) return;
                        setState(() => _processing = true);
                        final content =
                            '📊 ${questionController.text}\n${options.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}';
                        await ApiService.createPost(
                          userId: 1,
                          username: 'briaannaab',
                          content: content,
                        );
                        setState(() => _processing = false);
                        if (mounted) Navigator.pop(context);
                      },
                child: _processing
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Post Poll',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

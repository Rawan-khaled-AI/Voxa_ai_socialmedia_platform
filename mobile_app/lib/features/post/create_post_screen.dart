import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/voxa_button.dart';

class CreatePostScreen extends StatefulWidget {
  static const String routeName = AppRoutes.createPost;

  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _text = TextEditingController();

  bool get _canPost => _text.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _onPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post created (UI only)')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.fieldFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _text,
                maxLines: 6,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "What's on your mind?",
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _ActionChip(icon: Icons.image_outlined, text: 'Photo'),
                _ActionChip(icon: Icons.mic_none, text: 'Audio'),
                _ActionChip(icon: Icons.location_on_outlined, text: 'Location'),
              ],
            ),
            const Spacer(),
            VoxaButton(
              text: 'Post',
              enabled: _canPost,
              onTap: _onPost,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ActionChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textDark),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
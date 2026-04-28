import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';

class CreatePostScreen extends StatefulWidget {
  static const String routeName = '/create-post';

  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool isLoading = false;
  bool _isRecording = false;

  File? selectedImage;
  String? _audioPath;

  bool get _canPost =>
      (_textController.text.trim().isNotEmpty ||
          selectedImage != null ||
          _audioPath != null) &&
      !isLoading;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _audioPath = path;
      });

      return;
    }

    final hasPermission = await _audioRecorder.hasPermission();

    if (!hasPermission) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();

    final path =
        '${dir.path}/voxa_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
      ),
      path: path,
    );

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _onPost() async {
    if (!_canPost) return;

    setState(() => isLoading = true);

    try {
      final token = await AuthService().getToken();

      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      String? imageUrl;
      String? audioUrl;

      if (selectedImage != null) {
        imageUrl = await ApiService.uploadImage(selectedImage!, token);
      }

      if (_audioPath != null) {
        audioUrl = await ApiService.uploadAudio(File(_audioPath!), token);
      }

      await ApiService.post(
        '/posts/',
        {
          'text': _textController.text.trim(),
          'image_url': imageUrl,
          'audio_url': audioUrl,
        },
        token: token,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildActionIcon(
    IconData icon, {
    VoidCallback? onTap,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return InkWell(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coming soon')),
            );
          },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFF3ECFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0D0FF)),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.primary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildAudioPreview() {
    if (_audioPath == null && !_isRecording) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3ECFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0D0FF)),
        ),
        child: Row(
          children: [
            Icon(
              _isRecording ? Icons.fiber_manual_record : Icons.mic,
              color: _isRecording ? Colors.red : AppColors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isRecording ? 'Recording...' : 'Audio recorded',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (_audioPath != null && !_isRecording)
              IconButton(
                onPressed: () {
                  setState(() => _audioPath = null);
                },
                icon: const Icon(Icons.close),
                color: AppColors.textDark,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textDark,
                    ),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/voxa_logo_color.png',
                          height: 42,
                        ),
                      ),
                    ),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: _canPost
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: InkWell(
                        onTap: _canPost ? _onPost : null,
                        child: Center(
                          child: Text(
                            isLoading ? 'Posting...' : 'Post',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Row(
                  children: const [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/avatar_1.jpg'),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'cristina',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              _buildAudioPreview(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "what’s on your mind?",
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(
                  children: [
                    _buildActionIcon(
                      Icons.image_outlined,
                      onTap: pickImage,
                    ),
                    const SizedBox(width: 12),
                    _buildActionIcon(
                      _isRecording ? Icons.stop : Icons.mic_none,
                      onTap: _toggleRecording,
                      iconColor:
                          _isRecording ? Colors.white : AppColors.primary,
                      backgroundColor:
                          _isRecording ? Colors.red : const Color(0xFFF3ECFF),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
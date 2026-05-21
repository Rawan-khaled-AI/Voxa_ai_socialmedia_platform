import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
import '../profile/models/user_profile_model.dart';
import '../profile/services/profile_service.dart';
import 'widgets/media_preview.dart';
import 'widgets/voice_record_card.dart';

enum VoiceComposerState {
  idle,
  recording,
  recorded,
  playing,
}

class CreatePostScreen extends StatefulWidget {
  static const String routeName = '/create-post';

  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ProfileService _profileService = ProfileService();

  bool isLoading = false;

  VoiceComposerState _voiceState = VoiceComposerState.idle;

  Timer? _recordTimer;
  Duration _recordDuration = Duration.zero;

  File? selectedImage;
  String? _audioPath;
  UserProfileModel? currentUser;

  bool get _isRecording => _voiceState == VoiceComposerState.recording;

  bool get _isPlaying => _voiceState == VoiceComposerState.playing;

  bool get _hasVoice =>
      _voiceState != VoiceComposerState.idle || _audioPath != null;

  bool get _canPost {
    return (_textController.text.trim().isNotEmpty ||
            selectedImage != null ||
            _audioPath != null) &&
        !isLoading;
  }

  bool get _hasChanges {
    return _textController.text.trim().isNotEmpty ||
        selectedImage != null ||
        _audioPath != null ||
        _isRecording;
  }

  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  bool get _isArabicText {
    return isArabic(_textController.text);
  }

  String get _durationText {
    final minutes = _recordDuration.inMinutes.toString().padLeft(2, '0');
    final seconds =
        (_recordDuration.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      if (mounted) setState(() {});
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;

      setState(() {
        _voiceState = _audioPath == null
            ? VoiceComposerState.idle
            : VoiceComposerState.recorded;
      });
    });

    _loadCurrentUser();
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _textController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return;

      final profile = await _profileService.getMyProfile(token);

      if (!mounted) return;

      setState(() {
        currentUser = profile;
      });
    } catch (_) {}
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return;

    setState(() {
      selectedImage = File(picked.path);
    });
  }

  Future<void> _startRecording() async {
    final allowed = await _audioRecorder.hasPermission();
    if (!allowed) return;

    await _audioPlayer.stop();

    final dir = await getTemporaryDirectory();

    final path =
        '${dir.path}/voxa_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
      ),
      path: path,
    );

    _recordTimer?.cancel();
    _recordDuration = Duration.zero;

    _recordTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          _recordDuration = Duration(
            seconds: _recordDuration.inSeconds + 1,
          );
        });
      },
    );

    setState(() {
      _audioPath = null;
      _voiceState = VoiceComposerState.recording;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    final path = await _audioRecorder.stop();

    _recordTimer?.cancel();

    setState(() {
      _audioPath = path;
      _voiceState = VoiceComposerState.recorded;
    });
  }

  Future<void> _togglePlayback() async {
    if (_audioPath == null || _isRecording) return;

    if (_isPlaying) {
      await _audioPlayer.pause();

      setState(() {
        _voiceState = VoiceComposerState.recorded;
      });

      return;
    }

    await _audioPlayer.play(
      DeviceFileSource(_audioPath!),
    );

    setState(() {
      _voiceState = VoiceComposerState.playing;
    });
  }

  Future<void> _handleVoicePrimaryAction() async {
    if (_isRecording) {
      await _stopRecording();
      return;
    }

    await _togglePlayback();
  }

  Future<void> _deleteVoice() async {
    _recordTimer?.cancel();
    await _audioPlayer.stop();

    if (_isRecording) {
      try {
        await _audioRecorder.stop();
      } catch (_) {}
    }

    setState(() {
      _audioPath = null;
      _recordDuration = Duration.zero;
      _voiceState = VoiceComposerState.idle;
    });
  }

  Future<void> _confirmVoice() async {
    if (_isRecording) {
      await _stopRecording();
    }

    if (_audioPath == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice saved'),
      ),
    );
  }

  Future<void> _handleBack() async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Discard post?'),
          content: const Text('You have unsaved changes'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Keep editing'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );

    if (discard == true && mounted) {
      _recordTimer?.cancel();

      if (_isRecording) {
        try {
          await _audioRecorder.stop();
        } catch (_) {}
      }

      await _audioPlayer.stop();

      if (!mounted) return;

      Navigator.pop(context);
    }
  }

  Future<void> _onPost() async {
    if (!_canPost) return;

    if (_isRecording) {
      await _stopRecording();
    }

    setState(() {
      isLoading = true;
    });

    try {
      final token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Login required');
      }

      String? imageUrl;
      String? audioUrl;

      if (selectedImage != null) {
        imageUrl = await ApiService.uploadImage(
          selectedImage!,
          token,
        );
      }

      if (_audioPath != null) {
        audioUrl = await ApiService.uploadAudio(
          File(_audioPath!),
          token,
        );
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

      await _audioPlayer.stop();

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasProfileImage = currentUser?.profileImageUrl != null &&
        currentUser!.profileImageUrl!.isNotEmpty;

    final profileImageUrl = hasProfileImage
        ? '${ApiService.baseUrl}${currentUser!.profileImageUrl}'
        : null;

    final initial = currentUser?.name.isNotEmpty == true
        ? currentUser!.name[0].toUpperCase()
        : 'R';

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFAFD),
                Color(0xFFF6EDFF),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _handleBack,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            'assets/voxa_logo_clean.png',
                            height: 68,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _canPost ? _onPost : null,
                        child: Text(
                          isLoading ? '...' : 'POST',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFEEDBFF),
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl == null
                            ? Text(
                                initial,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Flexible(
                        child: Text(
                          currentUser?.name ?? 'Loading',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1E5FF),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text('🌍 Public'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Directionality(
                          textDirection: _isArabicText
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          child: TextField(
                            controller: _textController,
                            minLines: 1,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textAlign: _isArabicText
                                ? TextAlign.right
                                : TextAlign.left,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: _isArabicText
                                  ? 'ماذا يدور في ذهنك؟'
                                  : 'What’s on your mind?',
                              hintStyle: const TextStyle(
                                color: Color(0xFFA49AB6),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: _isArabicText ? 30 : 28,
                              height: 1.5,
                              color: AppColors.textDark,
                              fontWeight: _isArabicText
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        Align(
                          alignment: _isArabicText
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Text(
                            '${_textController.text.length}/500',
                            style: const TextStyle(
                              color: Color(0xFF9A92A8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _addImageCard(),
                        const SizedBox(height: 18),
                        MediaPreview(
                          imageFile: selectedImage,
                          onRemove: () {
                            setState(() {
                              selectedImage = null;
                            });
                          },
                        ),
                        if (_hasVoice)
                          VoiceRecordCard(
                            isRecording: _isRecording,
                            isPlaying: _isPlaying,
                            duration: _durationText,
                            onDelete: _deleteVoice,
                            onPrimary: _handleVoicePrimaryAction,
                            onDone: _confirmVoice,
                          ),
                        const SizedBox(height: 24),
                        if (!_hasVoice)
                          SizedBox(
                            width: double.infinity,
                            child: _action(
                              Icons.mic,
                              'Record Voice',
                              _startRecording,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _addImageCard() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        width: double.infinity,
        height: 76,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFD9B9FF),
            width: 1.2,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              color: AppColors.primary,
            ),
            SizedBox(width: 10),
            Text(
              'Add Image',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
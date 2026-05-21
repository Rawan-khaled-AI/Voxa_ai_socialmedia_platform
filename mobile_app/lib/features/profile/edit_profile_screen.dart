import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
import 'models/user_profile_model.dart';
import 'profile_photo_crop_screen.dart';
import 'services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final ProfileService _profileService =
      ProfileService();

  final ImagePicker _picker =
      ImagePicker();

  late final TextEditingController
      _nameController;

  late final TextEditingController
      _bioController;

  File? selectedImage;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
      text: widget.user.name,
    );

    _bioController =
        TextEditingController(
      text: widget.user.bio ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  bool get _canSave {
    return _nameController.text
            .trim()
            .isNotEmpty &&
        !isSaving;
  }

  String? get _currentImageUrl {
    final value =
        widget.user.profileImageUrl;

    if (value == null ||
        value.isEmpty ||
        value == 'string') {
      return null;
    }

    return '${ApiService.baseUrl}$value';
  }

  ImageProvider<Object>? get _profileImageProvider {
    if (selectedImage != null) {
      return FileImage(
        selectedImage!,
      );
    }

    if (_currentImageUrl != null) {
      return NetworkImage(
        _currentImageUrl!,
      );
    }

    return null;
  }

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );

    if (picked == null) return;

    final cropped =
        await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProfilePhotoCropScreen(
          imageFile: File(
            picked.path,
          ),
        ),
      ),
    );

    if (cropped == null) return;

    setState(() {
      selectedImage = cropped;
    });
  }

  Future<void> _saveProfile() async {
    if (!_canSave) return;

    setState(() {
      isSaving = true;
    });

    try {
      final token =
          await AuthService()
              .getToken();

      if (token == null) {
        throw Exception(
          'Login required',
        );
      }

      String? profileImageUrl =
          widget
              .user
              .profileImageUrl;

      if (selectedImage != null) {
        profileImageUrl =
            await ApiService
                .uploadImage(
          selectedImage!,
          token,
        );
      }

      await _profileService
          .updateProfile(
        token: token,
        name: _nameController.text
            .trim(),
        bio: _bioController.text
            .trim(),
        profileImageUrl:
            profileImageUrl,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,

          backgroundColor:
              const Color(
            0xFF2A2232,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),

          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final imageProvider =
        _profileImageProvider;

    final initial = _nameController
            .text
            .trim()
            .isNotEmpty
        ? _nameController.text
            .trim()[0]
            .toUpperCase()
        : 'R';

    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus();
      },

      child: Scaffold(
        backgroundColor:
            const Color(
          0xFFFFFAFD,
        ),

        body: Container(
          decoration:
              const BoxDecoration(
            gradient:
                LinearGradient(
              begin:
                  Alignment
                      .topCenter,
              end: Alignment
                  .bottomCenter,
              colors: [
                Color(
                  0xFFFFFAFD,
                ),
                Color(
                  0xFFF6EDFF,
                ),
              ],
            ),
          ),

          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child:
                      SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),

                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      24,
                      12,
                      24,
                      34,
                    ),

                    child: Column(
                      children: [
                        _buildAvatar(
                          imageProvider,
                          initial,
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal:
                                16,
                            vertical:
                                9,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .white
                                .withOpacity(
                              .72,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              999,
                            ),
                          ),

                          child: const Text(
                            'Tap avatar to change photo',

                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xFF8F889A,
                              ),

                              fontWeight:
                                  FontWeight
                                      .w700,

                              fontSize:
                                  13,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 32,
                        ),

                        _buildInputCard(
                          title:
                              'Display Name',

                          child:
                              _buildTextField(
                            controller:
                                _nameController,

                            icon: Icons
                                .person_outline,

                            hint:
                                'Your name',

                            maxLength:
                                50,
                          ),
                        ),

                        const SizedBox(
                          height: 22,
                        ),

                        _buildInputCard(
                          title:
                              'Bio',

                          child:
                              _buildTextField(
                            controller:
                                _bioController,

                            icon: Icons
                                .format_quote_rounded,

                            hint:
                                'Write something about you...',

                            maxLength:
                                160,

                            minLines:
                                3,

                            maxLines:
                                5,
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        _buildPreview(),

                        const SizedBox(
                          height: 34,
                        ),

                        _buildSaveButton(),

                        const SizedBox(
                          height: 12,
                        ),

                        TextButton(
                          onPressed:
                              isSaving
                                  ? null
                                  : () {
                                      Navigator.pop(
                                        context,
                                      );
                                    },

                          child:
                              const Text(
                            'Cancel',

                            style:
                                TextStyle(
                              color:
                                  AppColors
                                      .primary,

                              fontSize:
                                  16,

                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
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

  Widget _buildHeader() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        4,
      ),

      child: SizedBox(
        height: 58,

        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,

              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withOpacity(
                  .85,
                ),

                shape:
                    BoxShape.circle,
              ),

              child: IconButton(
                onPressed:
                    isSaving
                        ? null
                        : () {
                            Navigator.pop(
                              context,
                            );
                          },

                icon: const Icon(
                  Icons
                      .arrow_back_ios_new,

                  color: AppColors
                      .primary,

                  size: 20,
                ),
              ),
            ),

            const Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: [
                  Text(
                    'Edit Profile',

                    style:
                        TextStyle(
                      color:
                          AppColors
                              .textDark,

                      fontSize: 23,

                      fontWeight:
                          FontWeight
                              .w900,
                    ),
                  ),

                  SizedBox(
                    height: 2,
                  ),

                  Text(
                    'make your profile feel more you ✨',

                    style:
                        TextStyle(
                      color:
                          Color(
                        0xFF8F889A,
                      ),

                      fontSize: 12.5,

                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 44,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(
    ImageProvider<Object>? imageProvider,
    String initial,
  ) {
    return GestureDetector(
      onTap: _pickImage,

      child: Stack(
        alignment:
            Alignment.bottomRight,

        children: [
          Container(
            padding:
                const EdgeInsets
                    .all(6),

            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,

              gradient:
                  const LinearGradient(
                colors: [
                  Color(
                    0xFFE9C8FF,
                  ),
                  Color(
                    0xFFD86BFF,
                  ),
                ],
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors
                      .purple
                      .withOpacity(
                    .15,
                  ),

                  blurRadius: 24,

                  offset:
                      const Offset(
                    0,
                    10,
                  ),
                ),
              ],
            ),

            child: CircleAvatar(
              radius: 72,

              backgroundColor:
                  Colors.white,

              backgroundImage:
                  imageProvider,

              child:
                  imageProvider ==
                          null
                      ? Text(
                          initial,

                          style:
                              const TextStyle(
                            color:
                                AppColors
                                    .primary,

                            fontWeight:
                                FontWeight
                                    .bold,

                            fontSize:
                                42,
                          ),
                        )
                      : null,
            ),
          ),

          Container(
            width: 56,
            height: 56,

            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,

              gradient:
                  const LinearGradient(
                colors: [
                  Color(
                    0xFFD86BFF,
                  ),
                  Color(
                    0xFF8E45FF,
                  ),
                ],
              ),

              border: Border.all(
                color:
                    Colors.white,

                width: 4,
              ),
            ),

            child: const Icon(
              Icons.camera_alt,

              color:
                  Colors.white,

              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(
          .88,
        ),

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        border: Border.all(
          color:
              const Color(
            0xFFEAD9FF,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.purple
                .withOpacity(.04),

            blurRadius: 18,

            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style:
                const TextStyle(
              color:
                  AppColors.textDark,

              fontWeight:
                  FontWeight.w800,

              fontSize: 15,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController
        controller,
    required IconData icon,
    required String hint,
    required int maxLength,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,

      minLines: minLines,

      maxLines: maxLines,

      maxLength: maxLength,

      onChanged: (_) {
        setState(() {});
      },

      decoration: InputDecoration(
        counterStyle:
            const TextStyle(
          color:
              Color(0xFF8F889A),

          fontWeight:
              FontWeight.w600,
        ),

        filled: true,

        fillColor:
            const Color(
          0xFFF9F3FF,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            22,
          ),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            22,
          ),

          borderSide:
              BorderSide.none,
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            22,
          ),

          borderSide:
              const BorderSide(
            color:
                AppColors.primary,

            width: 1.4,
          ),
        ),

        prefixIcon: Icon(
          icon,
          color:
              AppColors.primary,
        ),

        hintText: hint,

        hintStyle:
            const TextStyle(
          color:
              Color(0xFFA49AB6),
        ),

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),

      style: const TextStyle(
        color: AppColors.textDark,

        fontSize: 16,

        fontWeight: FontWeight.w600,

        height: 1.45,
      ),
    );
  }

  Widget _buildPreview() {
    final imageProvider =
        _profileImageProvider;

    final name = _nameController
            .text
            .trim()
            .isEmpty
        ? 'rawan'
        : _nameController.text
            .trim();

    final bio = _bioController
            .text
            .trim()
            .isEmpty
        ? 'just sharing my thoughts.. 💜'
        : _bioController.text
            .trim();

    final initial =
        name.isNotEmpty
            ? name[0]
                .toUpperCase()
            : 'R';

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFFFF9FF),
            Color(0xFFF5E8FF),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.purple
                .withOpacity(.05),

            blurRadius: 22,

            offset:
                const Offset(
              0,
              9,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 36,

            backgroundColor:
                const Color(
              0xFFEEDBFF,
            ),

            backgroundImage:
                imageProvider,

            child:
                imageProvider ==
                        null
                    ? Text(
                        initial,

                        style:
                            const TextStyle(
                          color:
                              AppColors
                                  .primary,

                          fontWeight:
                              FontWeight
                                  .bold,

                          fontSize:
                              24,
                        ),
                      )
                    : null,
          ),

          const SizedBox(
            width: 15,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  name,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    color: AppColors
                        .textDark,

                    fontSize: 18,

                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '@${name.toLowerCase()}.voxa',

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    color: AppColors
                        .primary,

                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  bio,

                  maxLines: 2,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    color: Color(
                      0xFF8F889A,
                    ),

                    fontWeight:
                        FontWeight
                            .w600,

                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,

      height: 60,

      child:
          ElevatedButton.icon(
        onPressed:
            _canSave
                ? _saveProfile
                : null,

        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,

                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color:
                      Colors.white,
                ),
              )
            : const Icon(
                Icons
                    .check_circle_outline,
              ),

        label: Text(
          isSaving
              ? 'Saving...'
              : 'Save Changes',
        ),

        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,

          foregroundColor:
              Colors.white,

          disabledBackgroundColor:
              const Color(
            0xFFD8B8FF,
          ),

          elevation: 0,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              24,
            ),
          ),

          textStyle:
              const TextStyle(
            fontSize: 17,

            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
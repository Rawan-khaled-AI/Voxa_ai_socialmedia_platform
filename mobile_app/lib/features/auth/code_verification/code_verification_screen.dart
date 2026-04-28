import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/voxa_button.dart';

class CodeVerificationScreen extends StatefulWidget {
  static const String routeName = AppRoutes.codeVerification;

  final bool isResetPasswordFlow;

  const CodeVerificationScreen({
    super.key,
    this.isResetPasswordFlow = false,
  });

  @override
  State<CodeVerificationScreen> createState() =>
      _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  static const int _otpLength = 6;
  static const int _resendSeconds = 60;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  bool get _isOtpComplete =>
      _controllers.every((c) => c.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });

    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _handleChange(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');

      for (int i = 0; i < _otpLength; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }

      _focusNodes.last.unfocus();
      setState(() {});

      if (_isOtpComplete) {
        Future.microtask(_confirm);
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus();
      }
    }

    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    setState(() {});

    if (_isOtpComplete) {
      Future.microtask(_confirm);
    }
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code resent')),
    );
    _startResendTimer();
  }

  void _confirm() {
    if (widget.isResetPasswordFlow) {
      Navigator.pushReplacementNamed(context, AppRoutes.newPassword);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account verified successfully')),
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.signIn,
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mm = _secondsLeft ~/ 60;
    final ss = _secondsLeft % 60;

    final resendText = _secondsLeft == 0
        ? 'Resend code'
        : 'Resend in ${_twoDigits(mm)}:${_twoDigits(ss)}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Code\nVerification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return SizedBox(
                    width: 44,
                    height: 52,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _handleChange(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _secondsLeft == 0 ? _resendCode : null,
                child: Text(
                  resendText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _secondsLeft == 0
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.45),
                  ),
                ),
              ),
              const Spacer(),
              VoxaButton(
                text: 'Confirm',
                enabled: _isOtpComplete,
                onTap: _confirm,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
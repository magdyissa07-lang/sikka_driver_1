import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  Future<void> _verify() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthService.verifyOtp(widget.phone, _codeCtrl.text.trim());
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('تأكيد رقم الهاتف', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('أرسلنا رمز التحقق إلى\n${widget.phone}',
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 30),
              TextField(
                controller: _codeCtrl,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 22, letterSpacing: 10, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: '••••'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _verify,
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onAccent))
                      : const Text('تأكيد'),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () async {
                  await AuthService.resendOtp(widget.phone);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال كود جديد')),
                    );
                  }
                },
                child: const Text('إعادة إرسال الكود', style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

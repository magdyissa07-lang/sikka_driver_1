import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/rating_service.dart';
import 'home_screen.dart';

class RatingScreen extends StatefulWidget {
  final int tripId;
  final double? finalFare;
  const RatingScreen({super.key, required this.tripId, this.finalFare});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _stars = 5;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await RatingService.rate(tripId: widget.tripId, stars: _stars, comment: _commentCtrl.text.trim());
    } finally {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 52),
              const SizedBox(height: 14),
              const Text('وصلت بالسلامة!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              if (widget.finalFare != null) ...[
                const SizedBox(height: 6),
                Text('السعر النهائي: ${widget.finalFare} ج.م', style: const TextStyle(color: AppColors.accent)),
              ],
              const SizedBox(height: 24),
              const Text('قيّم رحلتك مع السائق', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _stars;
                  return IconButton(
                    iconSize: 34,
                    icon: Icon(filled ? Icons.star : Icons.star_border, color: AppColors.accent),
                    onPressed: () => setState(() => _stars = i + 1),
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'تعليق (اختياري)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onAccent))
                      : const Text('إرسال التقييم'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

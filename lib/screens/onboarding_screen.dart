import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.directions_car_filled, color: AppColors.accent, size: 54),
              ),
              const SizedBox(height: 26),
              const Text('سيارات موديل 2020 فأحدث فقط',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                'كل سائق يمر بمراجعة موديل السيارة قبل التفعيل، لضمان تجربة راقية في كل رحلة',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('ابدأ الآن'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

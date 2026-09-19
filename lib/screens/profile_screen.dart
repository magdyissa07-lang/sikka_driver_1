import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/auth_service.dart';
import 'onboarding_screen.dart';
import 'packages_screen.dart';
import 'wallet_screen.dart';
import 'saved_places_screen.dart';
import 'support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.accent),
              title: const Text('المحفظة'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard, color: AppColors.accent),
              title: const Text('الباقات النشطة'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PackagesScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.place_outlined, color: AppColors.accent),
              title: const Text('الأماكن المحفوظة'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedPlacesScreen())),
            ),
            ListTile(leading: const Icon(Icons.language, color: AppColors.accent), title: const Text('اللغة')),
            ListTile(
              leading: const Icon(Icons.support_agent, color: AppColors.accent),
              title: const Text('الدعم الفني'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportScreen())),
            ),
            const Spacer(),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
              onPressed: () async {
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}

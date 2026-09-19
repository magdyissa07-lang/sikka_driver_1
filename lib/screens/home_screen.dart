import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'request_trip_screen.dart';
import 'packages_screen.dart';
import 'profile_screen.dart';
import 'carpool_schedule_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(backgroundColor: AppColors.accent, radius: 18, child: Text('أ')),
                  const Text('بيفرلي هيلز، الشيخ زايد', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.map_outlined, color: AppColors.textSecondary, size: 40),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.local_taxi),
                  label: const Text('طلب رحلة'),
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const RequestTripScreen())),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.card_giftcard, color: AppColors.accent),
                      label: const Text('الباقات'),
                      onPressed: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const PackagesScreen())),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.accent),
                      label: const Text('المحفظة'),
                      onPressed: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const WalletScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.school_outlined, color: AppColors.accent),
                  label: const Text('الرحلة المشتركة للمدرسة'),
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const CarpoolScheduleScreen())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

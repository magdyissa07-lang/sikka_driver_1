import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';
import 'home_screen.dart';
import 'rating_screen.dart';

/// بيعمل Polling كل 4 ثواني على حالة الرحلة. لاحقًا يستحسن استبداله بـ
/// WebSocket / Laravel Echo عشان تحديث فوري بدل السحب المتكرر.
class TripTrackingScreen extends StatefulWidget {
  final int tripId;
  const TripTrackingScreen({super.key, required this.tripId});

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  Trip? _trip;
  Timer? _timer;
  bool _navigatedToRating = false;

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    try {
      final trip = await TripService.show(widget.tripId);
      if (!mounted) return;
      setState(() => _trip = trip);
      if (trip.status == 'completed' && !_navigatedToRating) {
        _navigatedToRating = true;
        _timer?.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => RatingScreen(tripId: trip.id, finalFare: trip.finalFare)),
          );
        });
      }
    } catch (_) {
      // تجاهل فشل مؤقت في السحب، هيعيد المحاولة تلقائيًا في الدورة الجاية
    }
  }

  String _statusLabel(String status) => switch (status) {
        'searching' => 'جاري البحث عن سائق قريب...',
        'accepted' => 'السائق في الطريق إليك',
        'in_progress' => 'الرحلة جارية',
        'completed' => 'انتهت الرحلة',
        'cancelled' => 'تم إلغاء الرحلة',
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    return Scaffold(
      appBar: AppBar(title: const Text('الرحلة')),
      body: Center(
        child: trip == null
            ? const CircularProgressIndicator(color: AppColors.accent)
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trip.status == 'searching')
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                    Text(_statusLabel(trip.status), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    if (trip.finalFare != null)
                      Text('السعر النهائي: ${trip.finalFare} ج.م', style: const TextStyle(color: AppColors.accent)),
                    const SizedBox(height: 24),
                    if (trip.status == 'searching')
                      OutlinedButton(
                        onPressed: () async {
                          await TripService.cancel(trip.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        child: const Text('إلغاء الطلب'),
                      ),
                    if (trip.status == 'completed')
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        ),
                        child: const Text('العودة للرئيسية'),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

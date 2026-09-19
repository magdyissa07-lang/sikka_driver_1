import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/trip_service.dart';
import 'trip_tracking_screen.dart';

/// ملحوظة: نقطة الانطلاق/الوصول هنا إحداثيات تجريبية ثابتة لغرض تجربة
/// الاتصال بالـAPI بسرعة. في التطبيق الحقيقي دول هيتحددوا من الخريطة
/// (Google Maps Flutter) أو من مكتبة geolocator لموقع الراكب الحالي.
class RequestTripScreen extends StatefulWidget {
  const RequestTripScreen({super.key});
  @override
  State<RequestTripScreen> createState() => _RequestTripScreenState();
}

class _RequestTripScreenState extends State<RequestTripScreen> {
  static const _pickup = (lat: 29.9900, lng: 30.9300);
  static const _dropoff = (lat: 30.0200, lng: 31.0000);

  bool _loadingEstimate = true;
  String? _error;
  List<dynamic> _estimates = [];
  double? _distanceKm;
  bool _isOutOfZone = false;
  String _selectedCategory = 'economy';
  String _paymentMethod = 'cash';
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _loadEstimate();
  }

  Future<void> _loadEstimate() async {
    try {
      final res = await TripService.estimate(
        pickupLat: _pickup.lat,
        pickupLng: _pickup.lng,
        dropoffLat: _dropoff.lat,
        dropoffLng: _dropoff.lng,
      );
      setState(() {
        _estimates = res['estimates'];
        _distanceKm = double.tryParse(res['distance_km'].toString());
        _isOutOfZone = res['is_out_of_zone'] == true;
        _loadingEstimate = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingEstimate = false;
      });
    }
  }

  Future<void> _confirm() async {
    setState(() => _requesting = true);
    try {
      final trip = await TripService.requestTrip(
        pickupLat: _pickup.lat,
        pickupLng: _pickup.lng,
        pickupText: 'فيلا 12، بيفرلي هيلز',
        dropoffLat: _dropoff.lat,
        dropoffLng: _dropoff.lng,
        dropoffText: 'مدرسة النيل الدولية',
        category: _selectedCategory,
        paymentMethod: _paymentMethod,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TripTrackingScreen(tripId: trip.id)),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد الرحلة'), leading: const BackButton()),
      body: _loadingEstimate
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null && _estimates.isEmpty
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.danger)))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isOutOfZone)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'وجهتك خارج نطاق الانتشار الحالي - قد يتأخر إيجاد سائق',
                            style: TextStyle(color: AppColors.warning, fontSize: 12.5),
                          ),
                        ),
                      Text('المسافة: ${_distanceKm?.toStringAsFixed(1)} كم',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 14),
                      const Text('اختر الفئة', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ..._estimates.map((e) {
                        final selected = _selectedCategory == e['category'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedCategory = e['category']),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: selected ? AppColors.accent : AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_categoryLabel(e['category'])),
                                  Text('${e['estimated_fare']} ج.م', style: const TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['cash', 'wallet', 'package'].map((m) {
                          final selected = _paymentMethod == m;
                          return ChoiceChip(
                            label: Text(_paymentLabel(m)),
                            selected: selected,
                            onSelected: (_) => setState(() => _paymentMethod = m),
                            selectedColor: AppColors.accent,
                            labelStyle: TextStyle(color: selected ? AppColors.onAccent : AppColors.text),
                            backgroundColor: AppColors.surface,
                          );
                        }).toList(),
                      ),
                      const Spacer(),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _requesting ? null : _confirm,
                          child: _requesting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onAccent))
                              : const Text('تأكيد الطلب'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _categoryLabel(String c) => switch (c) {
        'economy' => 'اقتصادية بريميوم',
        'plus' => 'بلس',
        'family' => 'فاخرة',
        _ => c,
      };

  String _paymentLabel(String m) => switch (m) {
        'cash' => 'نقدًا',
        'wallet' => 'المحفظة',
        'package' => 'من الباقة',
        _ => m,
      };
}

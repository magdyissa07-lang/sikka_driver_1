import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/area.dart';
import '../services/area_service.dart';
import '../services/auth_service.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  List<Area> _areas = [];
  Area? _selectedArea;
  String _residenceType = 'compound';
  bool _loadingAreas = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      final areas = await AreaService.list();
      setState(() {
        _areas = areas;
        _loadingAreas = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل المناطق. تأكد إن السيرفر شغال.';
        _loadingAreas = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty || _selectedArea == null) {
      setState(() => _error = 'من فضلك أكمل كل البيانات واختر المنطقة');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      // ملحوظة: pickup_lat/lng هنا قيم افتراضية تقريبية لمنطقة القاهرة الكبرى -
      // في التطبيق الحقيقي لازم تيجي من مكتبة تحديد الموقع (geolocator) أو
      // من تحديد الراكب الدبوس يدويًا على الخريطة.
      await AuthService.register(
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        residenceType: _residenceType,
        areaId: _selectedArea!.id,
        residenceFreeText: _addressCtrl.text.trim(),
        pickupLat: 29.99,
        pickupLng: 30.93,
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpScreen(phone: _phoneCtrl.text.trim())),
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
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إنشاء حساب جديد', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('سجّل بياناتك للبدء في استخدام التطبيق',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 20),

              const Text('الاسم الكامل', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'مثال: أحمد محمد')),
              const SizedBox(height: 14),

              const Text('رقم الهاتف', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '01012345678'),
              ),
              const SizedBox(height: 14),

              const Text('نوع السكن', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _residenceType = 'compound'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _residenceType == 'compound' ? AppColors.accent.withOpacity(0.14) : null,
                        side: BorderSide(color: _residenceType == 'compound' ? AppColors.accent : AppColors.border),
                      ),
                      child: Text('كمباوند',
                          style: TextStyle(color: _residenceType == 'compound' ? AppColors.accent : AppColors.text)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _residenceType = 'city'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _residenceType == 'city' ? AppColors.accent.withOpacity(0.14) : null,
                        side: BorderSide(color: _residenceType == 'city' ? AppColors.accent : AppColors.border),
                      ),
                      child: Text('مدينة / منطقة أخرى',
                          style: TextStyle(color: _residenceType == 'city' ? AppColors.accent : AppColors.text)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              const Text('المنطقة', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              _loadingAreas
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(color: AppColors.accent),
                    )
                  : DropdownButtonFormField<Area>(
                      value: _selectedArea,
                      dropdownColor: AppColors.surface,
                      items: _areas
                          .map((a) => DropdownMenuItem(value: a, child: Text('${a.nameAr} ${a.isActive ? "" : "(قريبًا)"}')))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedArea = v),
                      decoration: const InputDecoration(hintText: 'اختر المنطقة'),
                    ),
              if (_selectedArea != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_selectedArea!.isActive ? AppColors.success : AppColors.warning).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedArea!.isActive ? 'الخدمة متاحة الآن في منطقتك' : 'الخدمة قريبًا في منطقتك',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _selectedArea!.isActive ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),

              const Text('العنوان بالتفصيل', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(controller: _addressCtrl, decoration: const InputDecoration(hintText: 'مثال: فيلا 12، بيفرلي هيلز')),

              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],

              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onAccent))
                      : const Text('متابعة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

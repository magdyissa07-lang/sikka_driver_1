import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/package_service.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});
  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  List<dynamic> _packages = [];
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final packages = await PackageService.list();
      setState(() {
        _packages = packages;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _message = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _buy(int id) async {
    try {
      await PackageService.purchase(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء طلب الشراء - في انتظار الدفع عبر Paymob')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('باقات الكيلومترات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _message != null && _packages.isEmpty
              ? Center(child: Text(_message!, style: const TextStyle(color: AppColors.danger)))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _packages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final p = _packages[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text('صالحة ${p['validity_days']} يوم', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${p['price']} ج.م', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent)),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: () => _buy(p['id']),
                                style: ElevatedButton.styleFrom(minimumSize: const Size(80, 34), padding: const EdgeInsets.symmetric(horizontal: 14)),
                                child: const Text('شراء', style: TextStyle(fontSize: 12.5)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

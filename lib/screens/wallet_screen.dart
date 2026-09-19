import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 0;
  List<dynamic> _tx = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await WalletService.load();
    setState(() {
      _balance = data['balance'];
      _tx = data['transactions'];
      _loading = false;
    });
  }

  Future<void> _topup() async {
    final ctrl = TextEditingController();
    final amount = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('شحن المحفظة', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'المبلغ بالجنيه')),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('متابعة الدفع عبر Paymob')),
          ],
        ),
      ),
    );
    if (amount != null && double.tryParse(amount) != null) {
      final newBalance = await WalletService.topup(double.parse(amount));
      setState(() => _balance = newBalance);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحفظة')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFFB08D4C)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الرصيد الحالي', style: TextStyle(color: AppColors.onAccent, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text('${_balance.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(color: AppColors.onAccent, fontSize: 28, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.onAccent, foregroundColor: AppColors.accent),
                          onPressed: _topup,
                          child: const Text('شحن رصيد'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('آخر العمليات', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                if (_tx.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(child: Text('مفيش عمليات لسه', style: TextStyle(color: AppColors.textSecondary))),
                  ),
                ..._tx.map((t) {
                  final credit = t['type'] == 'credit';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(credit ? Icons.arrow_downward : Icons.arrow_upward, size: 18, color: credit ? AppColors.success : AppColors.danger),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_reasonLabel(t['reason']), style: const TextStyle(fontSize: 13))),
                        Text(
                          '${credit ? '+' : '-'}${t['amount']} ج.م',
                          style: TextStyle(fontWeight: FontWeight.w700, color: credit ? AppColors.success : AppColors.danger),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }

  String _reasonLabel(String r) => switch (r) {
        'trip_payment' => 'دفع رحلة',
        'topup' => 'شحن رصيد',
        'refund' => 'استرداد',
        'package_purchase' => 'شراء باقة',
        _ => r,
      };
}

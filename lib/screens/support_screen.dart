import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/support_service.dart';

const _categories = ['مشكلة في الدفع', 'سلوك سائق', 'مشكلة في الرحلة', 'استفسار عام'];

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List<dynamic> _tickets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await SupportService.list();
    setState(() {
      _tickets = list;
      _loading = false;
    });
  }

  Future<void> _newTicket() async {
    String category = _categories.first;
    final descCtrl = TextEditingController();
    final created = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('فتح تذكرة دعم فني', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: category,
                dropdownColor: AppColors.surface,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setSheet(() => category = v ?? category),
              ),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'اشرح المشكلة بالتفصيل')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: descCtrl.text.trim().isEmpty ? null : () => Navigator.pop(context, true),
                child: const Text('إرسال'),
              ),
            ],
          ),
        ),
      ),
    );
    if (created == true) {
      await SupportService.create(category: category, description: descCtrl.text.trim());
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم الفني'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _newTicket)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _tickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.support_agent, size: 44, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text('مفيش تذاكر دعم مفتوحة', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _newTicket, child: const Text('فتح تذكرة جديدة')),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final t = _tickets[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(t['category'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(t['status'] == 'open' ? 'مفتوحة' : 'مغلقة',
                                  style: TextStyle(fontSize: 12, color: t['status'] == 'open' ? AppColors.warning : AppColors.success)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(t['description'] ?? '', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

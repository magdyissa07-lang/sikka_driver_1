import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/saved_places_service.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});
  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  List<dynamic> _places = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final places = await SavedPlacesService.list();
    setState(() {
      _places = places;
      _loading = false;
    });
  }

  Future<void> _addPlace() async {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('إضافة مكان محفوظ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 14),
            TextField(controller: labelCtrl, decoration: const InputDecoration(hintText: 'الاسم (مثلاً: البيت، الشغل)')),
            const SizedBox(height: 10),
            TextField(controller: addressCtrl, decoration: const InputDecoration(hintText: 'العنوان بالتفصيل')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
    if (saved == true && labelCtrl.text.trim().isNotEmpty) {
      await SavedPlacesService.add(label: labelCtrl.text.trim(), addressText: addressCtrl.text.trim());
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأماكن المحفوظة'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addPlace)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _places.isEmpty
              ? const Center(child: Text('مفيش أماكن محفوظة لسه', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _places.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = _places[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.place_outlined, color: AppColors.accent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['label'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(p['address_text'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                            onPressed: () async {
                              await SavedPlacesService.remove(p['id']);
                              _load();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

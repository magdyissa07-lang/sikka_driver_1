import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/carpool_service.dart';

const _days = {'sun': 'أحد', 'mon': 'اثنين', 'tue': 'ثلاثاء', 'wed': 'أربعاء', 'thu': 'خميس'};

class CarpoolScheduleScreen extends StatefulWidget {
  const CarpoolScheduleScreen({super.key});
  @override
  State<CarpoolScheduleScreen> createState() => _CarpoolScheduleScreenState();
}

class _CarpoolScheduleScreenState extends State<CarpoolScheduleScreen> {
  List<dynamic> _schedules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await CarpoolService.list();
    setState(() {
      _schedules = list;
      _loading = false;
    });
  }

  Future<void> _createSchedule() async {
    final childCtrl = TextEditingController();
    final schoolCtrl = TextEditingController();
    TimeOfDay pickup = const TimeOfDay(hour: 7, minute: 0);
    TimeOfDay ret = const TimeOfDay(hour: 14, minute: 0);
    final selectedDays = <String>{'sun', 'mon', 'tue', 'wed', 'thu'};

    final created = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('جدولة رحلة مدرسية', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),
                const Text('هيتطرح طلب الرحلة تلقائيًا في المعاد ده كل يوم مختار، وهيتجمع مع ركاب تانيين رايحين نفس المدرسة.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 14),
                TextField(controller: childCtrl, decoration: const InputDecoration(hintText: 'اسم الطفل')),
                const SizedBox(height: 10),
                TextField(controller: schoolCtrl, decoration: const InputDecoration(hintText: 'اسم المدرسة')),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final t = await showTimePicker(context: context, initialTime: pickup);
                          if (t != null) setSheet(() => pickup = t);
                        },
                        child: Text('الذهاب: ${pickup.format(context)}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final t = await showTimePicker(context: context, initialTime: ret);
                          if (t != null) setSheet(() => ret = t);
                        },
                        child: Text('العودة: ${ret.format(context)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Align(alignment: Alignment.centerRight, child: Text('الأيام', style: TextStyle(fontWeight: FontWeight.w700))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: _days.entries.map((e) {
                    final selected = selectedDays.contains(e.key);
                    return FilterChip(
                      label: Text(e.value),
                      selected: selected,
                      onSelected: (v) => setSheet(() => v ? selectedDays.add(e.key) : selectedDays.remove(e.key)),
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(color: selected ? AppColors.onAccent : AppColors.text, fontSize: 12.5),
                      backgroundColor: AppColors.field,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: childCtrl.text.trim().isEmpty && schoolCtrl.text.trim().isEmpty
                      ? null
                      : () => Navigator.pop(context, true),
                  child: const Text('تفعيل الجدولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (created == true) {
      await CarpoolService.create(
        childName: childCtrl.text.trim().isEmpty ? 'الطفل' : childCtrl.text.trim(),
        schoolName: schoolCtrl.text.trim().isEmpty ? 'المدرسة' : schoolCtrl.text.trim(),
        pickupTime: '${pickup.hour}:${pickup.minute.toString().padLeft(2, '0')}',
        returnTime: '${ret.hour}:${ret.minute.toString().padLeft(2, '0')}',
        daysOfWeek: selectedDays.toList(),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرحلة المشتركة للمدرسة'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _createSchedule)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _schedules.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_outlined, size: 44, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        const Text('مفيش جدولة مدرسية لسه', style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _createSchedule, child: const Text('إضافة جدولة')),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _schedules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = _schedules[i];
                    final active = s['status'] == 'active';
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${s['child_name']} → ${s['school_name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text('${s['pickup_time']} ذهاب • ${s['return_time']} عودة',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Switch(
                            value: active,
                            activeThumbColor: AppColors.accent,
                            onChanged: (v) async {
                              await CarpoolService.setPaused(s['id'], !v);
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

import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SikkaRiderApp());
}

class SikkaRiderApp extends StatelessWidget {
  const SikkaRiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سِكّة',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('ar'),
      // ملحوظة: للحصول على RTL كامل مع نصوص Flutter المدمجة (زي أزرار
      // التاريخ)، أضف flutter_localizations في pubspec لاحقًا. الشاشات هنا
      // كلها Directionality: rtl يدويًا فبتشتغل صح حتى من غيرها.
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const SplashScreen(),
    );
  }
}

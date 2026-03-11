import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';
import 'package:ecommerce/features/home/presentation/screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ToastificationWrapper(
          child: MaterialApp(
            title: 'E-commerce',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.dark().textTheme,
              ).copyWith(
                displayLarge: GoogleFonts.afacadFlux(
                  textStyle: ThemeData.dark().textTheme.displayLarge,
                  fontWeight: FontWeight.bold,
                ),
                titleLarge: GoogleFonts.afacadFlux(
                  textStyle: ThemeData.dark().textTheme.titleLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}



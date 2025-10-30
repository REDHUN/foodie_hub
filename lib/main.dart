import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/providers/cart_provider.dart';
import 'package:foodiehub/providers/menu_cart_provider.dart';
import 'package:foodiehub/providers/product_provider.dart';
import 'package:foodiehub/screens/new_home_screen.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => MenuCartProvider()),
      ],
      child: MaterialApp(
        title: 'FoodieHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.lightColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.darkColor),
            titleTextStyle: TextStyle(
              color: AppColors.darkColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: const NewHomeScreen(),
    );
  }
}

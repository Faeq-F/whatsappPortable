import 'package:flutter/material.dart';

const String appVersion = '2.3.0';
const String remoteVersionUrl =
    'https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/Version';
const String repoReleasesUrl =
    'https://github.com/Faeq-F/whatsappPortable/releases';

final navigatorKey = GlobalKey<NavigatorState>();

final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.white,
      brightness: Brightness.light,
      primary: Colors.green,
    ),
    brightness: Brightness.light,
    inputDecorationTheme: InputDecorationTheme(fillColor: Colors.grey.shade300),
    canvasColor: Colors.white,
    cardColor: Colors.white,
    primaryColor: Colors.green,
    hintColor: Colors.black54,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
    dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
    iconTheme: const IconThemeData(color: Colors.black),
    navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.white,
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: Colors.black))));

final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.black,
      brightness: Brightness.dark,
      primary: Colors.green,
    ),
    brightness: Brightness.dark,
    inputDecorationTheme: InputDecorationTheme(fillColor: Colors.grey.shade900),
    canvasColor: Colors.black,
    cardColor: Colors.black,
    primaryColor: Colors.green,
    hintColor: Colors.white60,
    dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF212121)),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
    iconTheme: const IconThemeData(color: Colors.white),
    navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.black,
        indicatorColor: Colors.black,
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: Colors.white))));

import 'package:flutter/material.dart';
import 'package:webview_win_floating/webview_win_floating.dart';

final navigatorKey = GlobalKey<NavigatorState>();
WinWebViewController browserController = WinWebViewController();

final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    inputDecorationTheme: InputDecorationTheme(fillColor: Colors.grey.shade300),
    canvasColor: Colors.white,
    cardColor: Colors.white,
    primaryColor: Colors.red,
    hintColor: Colors.black54,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
    dialogBackgroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.black),
    navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.white,
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: Colors.black))));

final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    inputDecorationTheme: InputDecorationTheme(fillColor: Colors.grey.shade900),
    canvasColor: Colors.black,
    cardColor: Colors.black,
    primaryColor: Colors.red,
    hintColor: Colors.white60,
    dialogBackgroundColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
    iconTheme: const IconThemeData(color: Colors.white),
    navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.black,
        indicatorColor: Colors.black,
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: Colors.white))));

String lightModeJS = """
  var style = document.createElement("style");
  style.innerHTML =

  $fillScreen

  $removeDownloadForWindows

  "body{"+
    "background:#fff !important;"+
  "}"+

  "._ap4q::after {"+
    "background-color: #fff !important;"+
  "}";

  var ref = document.querySelector("script");
  ref.parentNode.insertBefore(style, ref);
  document.getElementsByTagName("body")[0].classList = [""];
""";

String darkModeJS = """
  var style = document.createElement("style");
  style.innerHTML =

  $fillScreen

  $removeDownloadForWindows

  "body{"+
    "background:#000 !important;"+
  "}"+

  "._ap4q::after {"+
    "background-color: #000 !important;"+
  "}";

  var ref = document.querySelector("script");
  ref.parentNode.insertBefore(style, ref);
  document.getElementsByTagName("body")[0].classList = ["dark"];
""";

String fillScreen = """
  ".app-wrapper-web ._aigs {" +
    "top: 0 !important;" +
    "width: 100vw !important;" +
    "height: 100vh !important;" +
    "max-width: 100vw !important;" +
    "margin: 0 !important;" +
    "box-shadow: 0 !important;" +
  "}"+

  "._al_d{"+
    "display: none !important;"+
  "}"+

  "#app{"+
    "border-radius: 15px !important;"+
  "}"+
""";

String removeDownloadForWindows = """
  "div > div[style=\\"opacity: 1;\\"] {"+
      "display: none;"+
  "}"+
""";

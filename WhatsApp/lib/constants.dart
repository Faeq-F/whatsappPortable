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
    hintColor: Colors.blueAccent,
    scaffoldBackgroundColor: Colors.grey.shade300,
    appBarTheme: AppBarTheme(backgroundColor: Colors.grey.shade300),
    dialogBackgroundColor: Colors.grey.shade300,
    navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.grey.shade300,
        indicatorColor: Colors.white,
        iconTheme:
            const WidgetStatePropertyAll(IconThemeData(color: Colors.black))));

final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    inputDecorationTheme: InputDecorationTheme(fillColor: Colors.grey.shade900),
    canvasColor: Colors.black,
    cardColor: Colors.black,
    primaryColor: Colors.red,
    hintColor: Colors.blueAccent,
    dialogBackgroundColor: Colors.grey.shade900,
    scaffoldBackgroundColor: Colors.grey.shade900,
    appBarTheme: AppBarTheme(backgroundColor: Colors.grey.shade900),
    navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.grey.shade900,
        indicatorColor: Colors.black54,
        iconTheme:
            const WidgetStatePropertyAll(IconThemeData(color: Colors.white))));

String lightModeJS = """
        var style = document.createElement("style");
        style.innerHTML =

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

import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    inputDecorationTheme: InputDecorationTheme(fillColor: Colors.grey.shade300),
    canvasColor: Colors.white,
    cardColor: Colors.white,
    primaryColor: Colors.green,
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
    primaryColor: Colors.green,
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

/// JavaScript to override the browser Notification API.
/// Intercepts notification creation and close events, and posts messages
/// back to Flutter via the NotificationChannel JS channel.
String notificationOverrideJS = """
(function() {
  if (window.__notificationOverrideInstalled) return;
  window.__notificationOverrideInstalled = true;

  window.activeNotifications = new Set();

  function CustomNotification(title, options) {
    this.title = title;
    this.options = options || {};
    this.id = Math.random().toString(36).substring(2, 9);
    window.activeNotifications.add(this.id);

    try {
      NotificationChannel.postMessage(JSON.stringify({
        type: 'NOTIFICATION_RECEIVED',
        id: this.id,
        title: this.title,
        body: this.options.body || '',
        remainingCount: window.activeNotifications.size
      }));
    } catch(e) {}

    var self = this;
    this.close = function() {
      if (window.activeNotifications.has(self.id)) {
        window.activeNotifications.delete(self.id);
        try {
          NotificationChannel.postMessage(JSON.stringify({
            type: 'NOTIFICATION_CLOSED',
            id: self.id,
            remainingCount: window.activeNotifications.size
          }));
        } catch(e) {}
      }
    };

    this.addEventListener = function(event, callback) {
      if (event === 'close') {
        var originalClose = self.close;
        self.close = function() {
          originalClose.call(self);
          callback();
        };
      }
    };
  }

  CustomNotification.permission = 'granted';
  CustomNotification.requestPermission = function() {
    return Promise.resolve('granted');
  };

  window.Notification = CustomNotification;
})();
""";

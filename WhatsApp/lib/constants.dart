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

  // Keep a reference to the native browser Notification constructor
  const NativeNotification = window.Notification;
  window.activeNotifications = new Set();

  function CustomNotification(title, options) {
    var self = this;
    this.title = title;
    this.options = options || {};
    this.id = Math.random().toString(36).substring(2, 9);
    window.activeNotifications.add(this.id);

    // Create the native notification to show the desktop popup
    let native = null;
    if (NativeNotification) {
      try {
        native = new NativeNotification(title, options);
      } catch (e) {
        console.error("Failed to create native notification:", e);
      }
    }

    try {
      NotificationChannel.postMessage(JSON.stringify({
        type: 'NOTIFICATION_RECEIVED',
        id: this.id,
        title: this.title,
        body: this.options.body || '',
        remainingCount: window.activeNotifications.size
      }));
    } catch(e) {}

    this.close = function() {
      if (window.activeNotifications.has(self.id)) {
        window.activeNotifications.delete(self.id);
        if (native && typeof native.close === 'function') {
          try {
            native.close();
          } catch(e) {}
        }
        try {
          NotificationChannel.postMessage(JSON.stringify({
            type: 'NOTIFICATION_CLOSED',
            id: self.id,
            remainingCount: window.activeNotifications.size
          }));
        } catch(e) {}
      }
    };

    // Forward standard properties and events to the native instance
    if (native) {
      Object.defineProperty(this, 'onclick', {
        get: function() { return native.onclick; },
        set: function(val) {
          native.onclick = function() {
            try {
              NotificationChannel.postMessage(JSON.stringify({
                type: 'NOTIFICATION_CLICKED',
                id: self.id
              }));
            } catch(e) {}
            if (typeof val === 'function') val.apply(this, arguments);
          };
        }
      });
      Object.defineProperty(this, 'onclose', {
        get: function() { return native.onclose; },
        set: function(val) {
          native.onclose = function() {
            self.close(); // Clean up tracker on close
            if (typeof val === 'function') val.apply(this, arguments);
          };
        }
      });
      Object.defineProperty(this, 'onerror', {
        get: function() { return native.onerror; },
        set: function(val) { native.onerror = val; }
      });
      Object.defineProperty(this, 'onshow', {
        get: function() { return native.onshow; },
        set: function(val) { native.onshow = val; }
      });
    }

    this.addEventListener = function(event, callback) {
      if (native && typeof native.addEventListener === 'function') {
        try {
          if (event === 'click') {
            native.addEventListener('click', function() {
              try {
                NotificationChannel.postMessage(JSON.stringify({
                  type: 'NOTIFICATION_CLICKED',
                  id: self.id
                }));
              } catch(e) {}
              if (typeof callback === 'function') callback.apply(this, arguments);
            });
          } else {
            native.addEventListener(event, callback);
          }
        } catch(e) {}
      }
      if (event === 'close') {
        var originalClose = self.close;
        self.close = function() {
          originalClose.call(self);
          callback();
        };
      }
    };
  }

  // Inherit static properties and requestPermission
  if (NativeNotification) {
    CustomNotification.permission = NativeNotification.permission;
    CustomNotification.requestPermission = function(callback) {
      var result = NativeNotification.requestPermission(callback);
      if (result && typeof result.then === 'function') {
        return result;
      }
      return Promise.resolve(CustomNotification.permission);
    };
  } else {
    CustomNotification.permission = 'granted';
    CustomNotification.requestPermission = function() {
      return Promise.resolve('granted');
    };
  }

  window.Notification = CustomNotification;
})();
""";

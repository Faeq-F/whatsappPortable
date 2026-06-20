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
  "section[data-testid=\\"intro-panel\\"] > :first-child {" +
      "display: none !important;" +
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

String translationJS = """
(function() {
  if (window.__translationOverrideInstalled) return;
  window.__translationOverrideInstalled = true;

  window.__translationTargetLangCode = 'en';
  window.__translationTargetLangName = 'English';

  window.setTargetLanguage = function(code, name) {
    window.__translationTargetLangCode = code;
    window.__translationTargetLangName = name;
  };

  document.addEventListener('contextmenu', function(e) {
    if (window.__skipTranslationMenu) return;
    const selectedText = window.getSelection().toString().trim();
    const bubble = e.target.closest('.message-in, .message-out, [data-id], [class*="message"]');
    if (selectedText || bubble) {
      e.preventDefault();
      e.stopPropagation();
      showCustomContextMenu(e.clientX, e.clientY, selectedText, bubble, e.target);
    }
  }, true);

  function showCustomContextMenu(x, y, selectedText, bubble, originalTarget) {
    removeCustomContextMenu();

    const menu = document.createElement('div');
    menu.id = 'custom-webview-translation-menu';
    menu.style.position = 'fixed';
    menu.style.left = x + 'px';
    menu.style.top = y + 'px';
    const isDark = document.body.classList.contains('dark');
    menu.style.backgroundColor = isDark ? '#233138' : '#ffffff';
    menu.style.color = isDark ? '#e9edef' : '#111b21';
    menu.style.border = '1px solid ' + (isDark ? '#374248' : '#e9edef');
    menu.style.borderRadius = '8px';
    menu.style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)';
    menu.style.padding = '8px 0';
    menu.style.zIndex = '10000';
    menu.style.fontFamily = 'Segoe UI, Helvetica Neue, Helvetica, Lucida Grande, Arial, Ubuntu, Cantarell, Fira Sans, sans-serif';
    menu.style.fontSize = '14px';
    menu.style.minWidth = '160px';
    menu.style.cursor = 'pointer';

    const option = document.createElement('div');
    const targetLangName = window.__translationTargetLangName || 'App Language';
    option.innerText = 'Translate to ' + targetLangName;
    option.style.padding = '8px 16px';
    option.addEventListener('mouseenter', () => {
      option.style.backgroundColor = isDark ? '#182229' : '#f0f2f5';
    });
    option.addEventListener('mouseleave', () => {
      option.style.backgroundColor = 'transparent';
    });

    option.addEventListener('click', function() {
      let textToTranslate = selectedText;
      if (!textToTranslate && bubble) {
        const copyable = bubble.querySelector('.copyable-text');
        textToTranslate = copyable ? copyable.innerText : bubble.innerText;
      }
      if (textToTranslate) {
        textToTranslate = textToTranslate.trim();
        textToTranslate = textToTranslate.replace(/\\s*\\d{1,2}:\\d{2}\\s*(?:AM|PM|am|pm)?\\s*\$/g, '');
        
        if (textToTranslate) {
          performTranslation(textToTranslate, bubble || document.body);
        }
      }
      removeCustomContextMenu();
    });

    menu.appendChild(option);

    // Add option to trigger native/whatsapp menu
    const optionsBtn = document.createElement('div');
    optionsBtn.innerText = 'WhatsApp Options';
    optionsBtn.style.padding = '8px 16px';
    optionsBtn.addEventListener('mouseenter', () => {
      optionsBtn.style.backgroundColor = isDark ? '#182229' : '#f0f2f5';
    });
    optionsBtn.addEventListener('mouseleave', () => {
      optionsBtn.style.backgroundColor = 'transparent';
    });
    optionsBtn.addEventListener('click', function() {
      removeCustomContextMenu();
      window.__skipTranslationMenu = true;
      const newEvent = new MouseEvent('contextmenu', {
        bubbles: true,
        cancelable: true,
        clientX: x,
        clientY: y,
        view: window
      });
      originalTarget.dispatchEvent(newEvent);
      setTimeout(() => {
        window.__skipTranslationMenu = false;
      }, 100);
    });
    menu.appendChild(optionsBtn);

    document.body.appendChild(menu);

    const closeHandler = function() {
      removeCustomContextMenu();
      document.removeEventListener('click', closeHandler);
    };
    setTimeout(() => document.addEventListener('click', closeHandler), 10);
  }

  function removeCustomContextMenu() {
    const existing = document.getElementById('custom-webview-translation-menu');
    if (existing) {
      existing.remove();
    }
  }

  function performTranslation(text, container) {
    const existing = container.querySelector('.custom-translation-bubble');
    if (existing) existing.remove();

    const transId = 'trans_' + Math.random().toString(36).substring(2, 9);

    const transBubble = document.createElement('div');
    transBubble.className = 'custom-translation-bubble';
    transBubble.setAttribute('data-translation-id', transId);
    transBubble.style.marginTop = '6px';
    transBubble.style.padding = '6px 8px';
    transBubble.style.borderRadius = '6px';
    transBubble.style.fontSize = '12.5px';
    transBubble.style.lineHeight = '1.4';
    transBubble.style.borderLeft = '3px solid #00a884';
    transBubble.style.position = 'relative';

    const isDark = document.body.classList.contains('dark');
    transBubble.style.backgroundColor = isDark ? '#1f2c34' : '#f0f2f5';
    transBubble.style.color = isDark ? '#e9edef' : '#111b21';

    const header = document.createElement('div');
    header.style.fontWeight = 'bold';
    header.style.fontSize = '11px';
    header.style.color = '#00a884';
    header.style.marginBottom = '2px';
    header.style.display = 'flex';
    header.style.justifyContent = 'space-between';
    header.style.alignItems = 'center';

    const title = document.createElement('span');
    title.innerText = 'Translation';
    header.appendChild(title);

    const closeBtn = document.createElement('span');
    closeBtn.innerText = '×';
    closeBtn.style.cursor = 'pointer';
    closeBtn.style.fontSize = '14px';
    closeBtn.style.fontWeight = 'bold';
    closeBtn.style.padding = '0 4px';
    closeBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      transBubble.remove();
    });
    header.appendChild(closeBtn);

    transBubble.appendChild(header);

    const bodyText = document.createElement('div');
    bodyText.className = 'translation-body-text';
    bodyText.innerText = 'Translating...';
    transBubble.appendChild(bodyText);

    container.appendChild(transBubble);

    const targetLang = window.__translationTargetLangCode || 'en';
    try {
      TranslationChannel.postMessage(JSON.stringify({
        id: transId,
        text: text,
        targetLang: targetLang
      }));
    } catch(e) {
      bodyText.innerText = 'Translation channel error';
    }
  }

  window.onTranslationReceived = function(transId, translatedText, isSuccess) {
    const bubble = document.querySelector('[data-translation-id="' + transId + '"]');
    if (bubble) {
      const bodyText = bubble.querySelector('.translation-body-text');
      if (bodyText) {
        bodyText.innerText = isSuccess ? translatedText : 'Translation failed';
      }
    }
  };
})();
""";

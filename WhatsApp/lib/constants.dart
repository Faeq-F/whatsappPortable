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

  $roundedCorners

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

  $roundedCorners

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

String roundedCorners = """
  "#app{"+
    "border-radius: 15px !important;"+
  "}"+
""";

String removeDownloadForWindows = """
  "section[data-testid=\\"intro-panel\\"] > :first-child {" +
      "display: none !important;" +
  "}"+
  "div[data-tab=\\"4\\"]:has(span[data-icon=\\"wa-square-icon\\"]) {" +
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
String getTranslationJS(String targetLangCode, String targetLangName, String tooltipLabel, bool enableHover, bool enableFullPage) {
  final escapedTooltip = tooltipLabel.replaceAll("'", "\\'");
  final escapedName = targetLangName.replaceAll("'", "\\'");
  return """
(function() {
  if (window.__translationOverrideInstalled) {
    if (window.setTargetLanguage) {
      window.setTargetLanguage('$targetLangCode', '$escapedName', '$escapedTooltip', $enableHover);
    }
    return;
  }
  window.__translationOverrideInstalled = true;

  window.__translationTargetLangCode = '$targetLangCode';
  window.__translationTargetLangName = '$escapedName';
  window.__translationTooltipLabel = '$escapedTooltip';
  window.__enableHoverTranslation = $enableHover;
  if (window.__enableHoverTranslation) {
    document.body.classList.remove('disable-hover-translation');
  } else {
    document.body.classList.add('disable-hover-translation');
  }

  window.setTargetLanguage = function(code, name, tooltipLabel, enableHover) {
    const oldCode = window.__translationTargetLangCode;
    window.__translationTargetLangCode = code;
    window.__translationTargetLangName = name;
    window.__translationTooltipLabel = tooltipLabel || name;
    window.__enableHoverTranslation = enableHover !== undefined ? enableHover : true;
    if (window.__enableHoverTranslation) {
      document.body.classList.remove('disable-hover-translation');
    } else {
      document.body.classList.add('disable-hover-translation');
    }
    const btns = document.querySelectorAll('.custom-translate-hover-btn');
    btns.forEach(btn => {
      btn.title = window.__translationTooltipLabel;
    });
    if (oldCode !== code && window.__fullPageTranslationActive) {
      translatedNodes = new WeakSet();
      scanAndTranslateDOM();
    }
  };

  const style = document.createElement('style');
  style.innerHTML = `
    .custom-translate-hover-btn {
      position: absolute;
      top: 6px;
      width: 22px;
      height: 22px;
      background-color: #00a884;
      border-radius: 50%;
      display: none;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      z-index: 999;
      box-shadow: 0 1px 3px rgba(0,0,0,0.3);
      color: white;
      font-size: 12px;
      user-select: none;
      transition: background-color 0.2s;
    }
    .custom-translate-hover-btn:hover {
      background-color: #008069;
    }
    body.disable-hover-translation .custom-translate-hover-btn {
      display: none !important;
    }
    [data-testid^="conv-msg"] {
      position: relative !important;
    }
    [data-testid^="conv-msg"]:hover .custom-translate-hover-btn {
      display: flex !important;
    }
    @keyframes translatePulse {
      0% { opacity: 0.4; }
      50% { opacity: 1.0; }
      100% { opacity: 0.4; }
    }
    .translation-body-text.loading {
      animation: translatePulse 1.5s infinite ease-in-out;
    }
  `;
  document.head.appendChild(style);

  document.addEventListener('mouseover', function(e) {
    if (window.__enableHoverTranslation === false) return;
    const bubble = e.target.closest('[data-testid="msg-container"]');
    if (bubble && !bubble.querySelector('.custom-translate-hover-btn') && !bubble.closest('.custom-translation-bubble')) {
      const btn = document.createElement('div');
      btn.className = 'custom-translate-hover-btn';
      btn.innerText = '🌐';
      btn.title = window.__translationTooltipLabel || (window.__translationTargetLangName || 'App Language');
      
      const isOutgoing = bubble.firstElementChild && bubble.firstElementChild.getAttribute('data-testid') === 'tail-out';
      if (isOutgoing) {
        btn.style.left = '-55px';
        btn.style.right = 'auto';
      } else {
        btn.style.right = '-55px';
        btn.style.left = 'auto';
      }
      
      btn.addEventListener('click', function(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        
        const selectableText = bubble.querySelector('.selectable-text');
        let textToTranslate = selectableText ? selectableText.innerText : bubble.innerText;
        if (textToTranslate) {
          textToTranslate = textToTranslate.trim();
          textToTranslate = textToTranslate.replace(/\\s*\\d{1,2}:\\d{2}\\s*(?:AM|PM|am|pm)?\\s*\$/g, '');
          if (textToTranslate) {
            performTranslation(textToTranslate, bubble);
          }
        }
      });
      bubble.appendChild(btn);
    }
  });

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
    bodyText.className = 'translation-body-text loading';
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

  window.translateAllMessages = function() {
    const bubbles = document.querySelectorAll('[data-testid="msg-container"]');
    bubbles.forEach(bubble => {
      if (bubble.closest('.custom-translation-bubble')) return;
      
      const selectableText = bubble.querySelector('.selectable-text');
      const text = selectableText ? selectableText.innerText : bubble.innerText;
      if (text) {
        let cleanText = text.trim();
        cleanText = cleanText.replace(/\\s*\\d{1,2}:\\d{2}\\s*(?:AM|PM|am|pm)?\\s*\$/g, '');
        if (cleanText && !bubble.querySelector('.custom-translation-bubble')) {
          performTranslation(cleanText, bubble);
        }
      }
    });
  };

  let translatedNodes = new WeakSet();
  let isScanning = false;

  function scanAndTranslateDOM() {
    if (isScanning) return;
    isScanning = true;

    try {
      const batchNodes = [];
      const batchTexts = [];

      function walk(node) {
        if (node.nodeType === 3) {
          const text = node.nodeValue.trim();
          if (text.length > 0 && !/^\\d+\$/.test(text) && !/^\\d{1,2}:\\d{2}\$/.test(text) && !translatedNodes.has(node)) {
            batchNodes.push(node);
            batchTexts.push(text);
          }
        } else if (node.nodeType === 1) {
          const tag = node.tagName.toLowerCase();
          if (tag !== 'script' && tag !== 'style' && tag !== 'noscript' && tag !== 'iframe') {
            const isWidget = node.classList && (node.classList.contains('custom-translate-hover-btn') || node.classList.contains('custom-translation-bubble'));
            if (!isWidget) {
              for (let child = node.firstChild; child; child = child.nextSibling) {
                walk(child);
              }
            }
          }
        }
      }

      if (document.body) {
        walk(document.body);
      }

      if (batchTexts.length === 0) {
        isScanning = false;
        return;
      }

      const chunkSize = 50;
      for (let i = 0; i < batchTexts.length; i += chunkSize) {
        const chunkNodes = batchNodes.slice(i, i + chunkSize);
        const chunkTexts = batchTexts.slice(i, i + chunkSize);
        
        const transId = 'batch_' + Math.random().toString(36).substring(2, 9);
        
        window.__batchMap = window.__batchMap || {};
        window.__batchMap[transId] = chunkNodes;

        chunkNodes.forEach(n => translatedNodes.add(n));

        try {
          TranslationChannel.postMessage(JSON.stringify({
            type: 'BATCH_TRANSLATE',
            id: transId,
            texts: chunkTexts,
            targetLang: window.__translationTargetLangCode
          }));
        } catch (e) {
          chunkNodes.forEach(n => translatedNodes.delete(n));
        }
      }
    } catch (err) {
      console.error("DOM translation error:", err);
    }
    
    isScanning = false;
  }

  window.translatePage = function() {
    if (window.__fullPageTranslationActive) return;
    window.__fullPageTranslationActive = true;
    
    scanAndTranslateDOM();

    const observer = new MutationObserver(() => {
      scanAndTranslateDOM();
    });
    observer.observe(document.body, {
      childList: true,
      subtree: true,
      characterData: true
    });
  };

  window.onBatchTranslationReceived = function(transId, translatedTexts, isSuccess) {
    const nodes = window.__batchMap ? window.__batchMap[transId] : null;
    if (nodes && isSuccess && translatedTexts.length === nodes.length) {
      nodes.forEach((node, idx) => {
        if (node && translatedTexts[idx]) {
          const original = node.nodeValue;
          const leadingWs = original.match(/^\\s*/)[0];
          const trailingWs = original.match(/\\s*\$/)[0];
          node.nodeValue = leadingWs + translatedTexts[idx] + trailingWs;
          translatedNodes.add(node);
        }
      });
    }
    if (window.__batchMap) {
      delete window.__batchMap[transId];
    }
  };

  window.onTranslationReceived = function(transId, translatedText, isSuccess) {
    const bubble = document.querySelector('[data-translation-id="' + transId + '"]');
    if (bubble) {
      const bodyText = bubble.querySelector('.translation-body-text');
      if (bodyText) {
        bodyText.className = 'translation-body-text';
        bodyText.innerText = isSuccess ? translatedText : 'Translation failed';
      }
    }
  };

  if ($enableFullPage) {
    if (document.readyState === 'complete') {
      window.translatePage();
    } else {
      window.addEventListener('load', () => window.translatePage());
    }
  }
})();
""";
}

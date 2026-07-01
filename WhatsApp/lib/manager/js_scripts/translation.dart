class TranslationJsScripts {
  static const String _translationStyles = """
  const style = document.createElement('style');
  style.innerHTML = `
    .custom-translate-hover-btn {
      position: absolute;
      top: 6px;
      width: 28px;
      height: 28px;
      background-color: transparent;
      border-radius: 50%;
      display: none;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      z-index: 999;
      box-shadow: none;
      color: #8696a0;
      font-size: 12px;
      user-select: none;
      transition: background-color 0.2s;
    }
    .custom-translate-hover-btn:hover {
      background-color: rgba(0,0,0,0.1);
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
""";

  static const String _translationHoverButton = """
  document.addEventListener('mouseover', function(e) {
    if (window.__enableHoverTranslation === false) return;
    const bubble = e.target.closest('[data-testid="msg-container"]');
    if (bubble && !bubble.querySelector('.custom-translate-hover-btn') && !bubble.closest('.custom-translation-bubble')) {
      const btn = document.createElement('div');
      btn.className = 'custom-translate-hover-btn';
      btn.innerHTML = `<svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M0 0h24v24H0V0z" fill="none"/><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zm6.93 6h-2.95c-.32-1.25-.78-2.45-1.38-3.56 1.84.63 3.37 1.91 4.33 3.56zM12 4.04c.83 1.2 1.48 2.53 1.91 3.96h-3.82c.43-1.43 1.08-2.76 1.91-3.96zM4.26 14C4.1 13.36 4 12.69 4 12s.1-1.36.26-2h3.38c-.08.66-.14 1.34-.14 2 0 .66.06 1.34.14 2H4.26zm.82 2h2.95c.32 1.25.78 2.45 1.38 3.56-1.84-.63-3.37-1.91-4.33-3.56zm2.95-8H5.08c.96-1.65 2.49-2.93 4.33-3.56C8.81 5.55 8.35 6.75 8.03 8zM12 19.96c-.83-1.2-1.48-2.53-1.91-3.96h3.82c-.43 1.43-1.08 2.76-1.91 3.96zM14.34 14H9.66c-.09-.66-.16-1.34-.16-2 0-.66.07-1.34.16-2h4.68c.09.66.16 1.34.16 2 0 .66-.07 1.34-.16 2zm.25 5.56c.6-1.11 1.06-2.31 1.38-3.56h2.95c-.96 1.65-2.49 2.93-4.33 3.56zM16.36 14c.08-.66.14-1.34.14-2 0-.66-.06-1.34-.14-2h3.38c.16.64.26 1.31.26 2s-.1 1.36-.26 2h-3.38z"/></svg>`;
      btn.title = window.__translationTooltipLabel || (window.__translationTargetLangName || 'App Language');
      
      const isOutgoing = bubble.firstElementChild && bubble.firstElementChild.getAttribute('data-testid') === 'tail-out';
      if (isOutgoing) {
        btn.style.left = '-65px';
        btn.style.right = 'auto';
      } else {
        btn.style.right = '-65px';
        btn.style.left = 'auto';
      }
      
      btn.addEventListener('click', function(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        
        let textToTranslate = getMessageText(bubble);
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
""";

  static const String _translationBubbleUI = """
  function performTranslation(text, container) {
    const existing = container.querySelector('.custom-translation-bubble');
    if (existing) existing.remove();

    const quotedNode = container.querySelector('[data-testid="quoted-message"] .selectable-text, .quoted-message .selectable-text');
    const quotedText = quotedNode ? quotedNode.innerText.trim() : null;

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
        quotedText: quotedText,
        targetLang: targetLang
      }));
    } catch(e) {
      bodyText.innerText = 'Translation channel error';
    }
  }
""";

  static const String _translateAllMessagesJS = """
  window.translateAllMessages = function() {
    const bubbles = document.querySelectorAll('[data-testid="msg-container"]');
    bubbles.forEach(bubble => {
      if (bubble.closest('.custom-translation-bubble')) return;
      
      const text = getMessageText(bubble);
      if (text) {
        let cleanText = text.trim();
        cleanText = cleanText.replace(/\\s*\\d{1,2}:\\d{2}\\s*(?:AM|PM|am|pm)?\\s*\$/g, '');
        if (cleanText && !bubble.querySelector('.custom-translation-bubble')) {
          performTranslation(cleanText, bubble);
        }
      }
    });
  };
""";

  static const String _translationEngineJS = """
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
              const placeholder = node.getAttribute('placeholder');
              const dataPlaceholder = node.getAttribute('data-placeholder');
              if ((placeholder && placeholder.trim().length > 0) || (dataPlaceholder && dataPlaceholder.trim().length > 0)) {
                if (!translatedNodes.has(node)) {
                  batchNodes.push(node);
                  batchTexts.push(((placeholder && placeholder.trim().length > 0) ? placeholder : dataPlaceholder).trim());
                }
              }
              const isEditable = node.isContentEditable || node.getAttribute('contenteditable') === 'true';
              if (!isEditable) {
                for (let child = node.firstChild; child; child = child.nextSibling) {
                  walk(child);
                }
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
""";

  static const String _translationCallbacksJS = """
  window.onBatchTranslationReceived = function(transId, translatedTexts, isSuccess) {
    const nodes = window.__batchMap ? window.__batchMap[transId] : null;
    if (nodes && isSuccess && translatedTexts.length === nodes.length) {
      nodes.forEach((node, idx) => {
        if (node && translatedTexts[idx]) {
          if (node.nodeType === 3) {
            const original = node.nodeValue;
            const leadingWs = original.match(/^\\s*/)[0];
            const trailingWs = original.match(/\\s*\$/)[0];
            node.nodeValue = leadingWs + translatedTexts[idx] + trailingWs;
            translatedNodes.add(node);
          } else if (node.nodeType === 1) {
            if (node.hasAttribute('placeholder')) {
              node.setAttribute('placeholder', translatedTexts[idx]);
            }
            if (node.hasAttribute('data-placeholder')) {
              node.setAttribute('data-placeholder', translatedTexts[idx]);
            }
            translatedNodes.add(node);
          }
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
        if (isSuccess) {
          if (translatedText.startsWith('{')) {
            try {
              const data = JSON.parse(translatedText);
              let quotedElement = bubble.querySelector('.quoted-translation');
              if (!quotedElement) {
                quotedElement = document.createElement('div');
                quotedElement.className = 'quoted-translation';
                quotedElement.style.borderLeft = '2px solid #8696a0';
                quotedElement.style.paddingLeft = '6px';
                quotedElement.style.color = '#8696a0';
                quotedElement.style.fontSize = '11.5px';
                quotedElement.style.marginBottom = '6px';
                quotedElement.style.fontStyle = 'italic';
                bodyText.parentNode.insertBefore(quotedElement, bodyText);
              }
              quotedElement.innerText = data.quoted;
              bodyText.innerText = data.response;
            } catch(e) {
              bodyText.innerText = translatedText;
            }
          } else {
            bodyText.innerText = translatedText;
          }
        } else {
          bodyText.innerText = 'Translation failed';
        }
      }
    }
  };
""";

  static String getTranslationJS(
    String targetLangCode,
    String targetLangName,
    String tooltipLabel,
    bool enableHover,
    bool enableFullPage,
  ) {
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

  function getMessageText(bubble) {
    const nodes = bubble.querySelectorAll('.selectable-text');
    for (let node of nodes) {
      if (node.closest('[data-testid="quoted-message"]') || node.closest('.quoted-message')) {
        continue;
      }
      return node.innerText;
    }
    if (nodes.length > 0) return nodes[nodes.length - 1].innerText;
    return bubble.innerText;
  }

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

  $_translationStyles

  $_translationHoverButton

  $_translationBubbleUI

  $_translateAllMessagesJS

  $_translationEngineJS

  $_translationCallbacksJS

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
}

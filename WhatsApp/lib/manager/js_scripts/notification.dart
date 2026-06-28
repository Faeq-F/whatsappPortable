class NotificationJsScripts {
  /// JavaScript to override the browser Notification API.
  /// Intercepts notification creation and close events, and posts messages
  /// back to Flutter via the NotificationChannel JS channel.
  static const String notificationOverrideJS = """
(function() {
  if (window.__notificationOverrideInstalled) return;
  window.__notificationOverrideInstalled = true;

  window.activeCustomNotifications = {};

  function CustomNotification(title, options) {
    var self = this;
    this.title = title;
    this.options = options || {};
    this.id = Math.random().toString(36).substring(2, 9);
    window.activeCustomNotifications[this.id] = this;

    this._listeners = {};

    try {
      NotificationChannel.postMessage(JSON.stringify({
        type: 'NOTIFICATION_RECEIVED',
        id: this.id,
        title: this.title,
        body: this.options.body || ''
      }));
    } catch(e) {}

    this.close = function() {
      if (window.activeCustomNotifications[self.id]) {
        delete window.activeCustomNotifications[self.id];
        try {
          NotificationChannel.postMessage(JSON.stringify({
            type: 'NOTIFICATION_CLOSED',
            id: self.id
          }));
        } catch(e) {}
      }
    };

    this.addEventListener = function(event, callback) {
      if (!self._listeners[event]) {
        self._listeners[event] = [];
      }
      self._listeners[event].push(callback);
    };

    this.removeEventListener = function(event, callback) {
      if (self._listeners[event]) {
        const idx = self._listeners[event].indexOf(callback);
        if (idx !== -1) {
          self._listeners[event].splice(idx, 1);
        }
      }
    };
  }

  // Inherit static properties and requestPermission
  CustomNotification.permission = 'granted';
  CustomNotification.requestPermission = function(callback) {
    if (typeof callback === 'function') callback('granted');
    return Promise.resolve('granted');
  };

  window.Notification = CustomNotification;

  window.onNotificationClicked = function(id) {
    const notification = window.activeCustomNotifications[id];
    if (notification) {
      if (typeof notification.onclick === 'function') {
        notification.onclick();
      }
      const listeners = notification._listeners['click'] || [];
      listeners.forEach(cb => {
        try { cb(); } catch(e) {}
      });
    }
  };

  window.onNotificationClosedFromServer = function(id) {
    const notification = window.activeCustomNotifications[id];
    if (notification) {
      if (typeof notification.onclose === 'function') {
        notification.onclose();
      }
      const listeners = notification._listeners['close'] || [];
      listeners.forEach(cb => {
        try { cb(); } catch(e) {}
      });
      delete window.activeCustomNotifications[id];
    }
  };
})();
""";
}

# A portable desktop WhatsApp application

Not endorsed or affiliated with WhatsApp.<br />
Written in Flutter using the [webview_win_floating](https://pub.dev/packages/webview_win_floating) package.<br />
To build the app, see [development and publishing documentation](docs/docs.md).

The [WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/?form=MA13LH) is required ([preinstalled onto all Windows 11 devices and eligible Windows 10 devices](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution?tabs=dotnetcsharp)).

### Features:

- No installation required
- All data stored in the relocatable app folder (making it truly portable)
- Use multiple WhatsApp accounts simultaneously
- Support for multiple languages & translation (via the $\color{red}{\text{Google Translate}}$ [API](https://docs.cloud.google.com/translate/docs/reference/rest))
- OS native notifications
- Themes: Light / Dark / System modes
- DevTools access

### Screenshots:

| ![Light mode](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-Light.png) | ![Dark mode](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-Dark.png) |
| :---: | :---: |
| Light mode | Dark mode |
| ![Logging in](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-Login.png) | ![Intro Panel](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-IntroPanel.png) |
| Logging in | Intro Panel |
 ![Settings dialog](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-Settings1.png) | ![Multiple accounts](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-Settings2-MultipleAccounts.png)
| Settings dialog | Multiple accounts |
| ![Update check dialog (light mode)](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-UpToDate.png) | ![Update check dialog (dark mode)](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-UpToDate-Dark.png) |
| Update check dialog (light mode) | Update check dialog (dark mode) |
| ![OS native notification](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-OS-NativeNotification.png) | ![Translated app UI](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-TranslatedAppUI.png) |
| OS native notification | Translated app UI |
| ![Entire page translation - open chat](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-TranslateEntirePage-OpenChat.png) | ![Entire page translation - intro panel](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-TranslateEntirePage-IntroPanel.png) |
| Entire page translation - open chat | Entire page translation - intro panel |
| ![Translate All Messages](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-TranslateAllMessages.png) | ![Translate Message Button](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-TranslateMessageButton.png) |
| Translated all messages | Translate message button |
| ![Notification with translated content](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-NotificationTranslatedContent.png) | ![Notification with translate button](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsAppPortable-NotificationTranslateButton.png) |
| Notification with translated content | Notification with translate button |
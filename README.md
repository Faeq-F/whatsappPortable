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

| ![Light mode]                                                  | ![Dark mode]                             |
| :---:                                                          | :---:                                    |
| Light mode                                                     | Dark mode                                |
| ![Logging in]                                                  | ![Intro Panel]                           |
| Logging in                                                     | Intro Panel                              |
| ![Settings dialog]                                             | ![Multiple accounts]                     |
| Settings dialog                                                | Multiple accounts                        |
| ![Update check dialog (light mode)]                            | ![Update check dialog (dark mode)]       |
| Update check dialog (light mode)                               | Update check dialog (dark mode)          |
| ![System Tray Task Icon] ![System Tray Task Notification Icon] |  ![System Tray Task Context Menu]        |
| System Tray Task Icon / Notification Icon                      | System Tray Task Context Menu            |
| ![OS native notification]                                      | ![Translated app UI]                     |
| OS native notification                                         | Translated app UI                        |
| ![Entire page translation - intro panel]                       | ![Entire page translation - open chat]   |
| Entire page translation - intro panel                          | Entire page translation - open chat      |
| ![Translate All Messages]                                      | ![Translate Message Button]              |
| Translated all messages                                        | Translate message button                 |
| ![Notification with translated content]                        | ![Notification with translate button]    |
| Notification with translated content                           | Notification with translate button       |


[Light mode]: ./docs/WhatsAppPortable-Light.png

[Dark mode]: ./docs/WhatsAppPortable-Dark.png

[Logging in]: ./docs/WhatsAppPortable-Login.png

[Intro Panel]: ./docs/WhatsAppPortable-IntroPanel.png

[Settings dialog]: ./docs/WhatsAppPortable-Settings1.png

[Multiple accounts]: ./docs/WhatsAppPortable-Settings2-MultipleAccounts.png

[Update check dialog (light mode)]: ./docs/WhatsAppPortable-UpToDate.png

[Update check dialog (dark mode)]: ./docs/WhatsAppPortable-UpToDate-Dark.png

[System Tray Task Icon]: ./docs/WhatsAppPortable-SystemTrayTaskIcon.png

[System Tray Task Notification Icon]: ./docs/WhatsAppPortable-SystemTrayTask-NotificationIcon.png

[System Tray Task Context Menu]: ./docs/WhatsAppPortable-SystemTrayTask-ContextMenu.png

[OS native notification]: ./docs/WhatsAppPortable-OS-NativeNotification.png

[Translated app UI]: ./docs/WhatsAppPortable-TranslatedAppUI.png

[Entire page translation - intro panel]: ./docs/WhatsAppPortable-TranslateEntirePage-IntroPanel.png

[Entire page translation - open chat]: ./docs/WhatsAppPortable-TranslateEntirePage-OpenChat.png

[Translate All Messages]: ./docs/WhatsAppPortable-TranslateAllMessages.png

[Translate Message Button]: ./docs/WhatsAppPortable-TranslateMessageButton.png

[Notification with translated content]: ./docs/WhatsAppPortable-NotificationTranslatedContent.png

[Notification with translate button]: ./docs/WhatsAppPortable-NotificationTranslateButton.png
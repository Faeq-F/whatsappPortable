# A portable desktop WhatsApp application

Not endorsed or affiliated with WhatsApp.<br />
Written in Flutter using the [webview_win_floating](https://pub.dev/packages/webview_win_floating) package.

The [WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/?form=MA13LH) is required ([preinstalled onto all Windows 11 devices and eligible Windows 10 devices](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution?tabs=dotnetcsharp)).

### Features:

- No installation required
- All data stored in the relocatable app folder (making it truly portable)
- Use multiple WhatsApp accounts simultaneously
- Notifications support
- Themes: Light / Dark / System modes
- DevTools access

### Screenshots:

![App Screenshot in light mode](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsappPortable.png)

![App Screenshot in dark mode](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsappPortable-Dark.png)

![App Screenshot when logging in](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsappPortable-Login.png)

![App Screenshot - settings dialog showing multiple accounts](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsappPortable-MultipleAccounts.png)

![App Screenshot - settings dialog (light mode)](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsappPortable-Settings.png)

![App Screenshot - settings dialog (dark mode)](https://raw.githubusercontent.com/Faeq-F/whatsappPortable/main/docs/WhatsappPortable-SettingsDark.png)

### Why?

I use a Gecko-based browser, the kind that WhatsApp Web seems to have a lot of trouble working with. I do not want to use other browsers and do not wish to use an installed desktop app. Other portable applications like [WhatsApp™ portable from portapps](https://portapps.io/app/whatsapp-portable/) have known [issues](https://github.com/portapps/whatsapp-portable/issues/64), preventing them from being useable.
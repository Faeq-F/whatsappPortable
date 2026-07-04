# Development & Publishing Documentation

## 1. Cloning the Repository

To start working on the project, clone the repository from GitHub and navigate to the project directory:

```bash
git clone https://github.com/Faeq-F/whatsappPortable.git
cd whatsappPortable
```

## 2. Prerequisites & Development Setup

Before building or running the application, ensure the following tools are installed:

- Flutter SDK
  - Since this is a Windows desktop application, Flutter requires Visual Studio for compilation:
      - Install [Visual Studio 2022](https://visualstudio.microsoft.com/) (Community edition is sufficient).
      - During installation, select the **Desktop development with C++** workload.
      - Ensure the following components are checked:
        - MSVC v143 build tools (or latest)
        - Windows 10 SDK (or 11)
        - CMake tools for Windows
  - Run `flutter doctor` in your terminal to verify that Flutter is correctly installed and all requirements are met.

### 2.4. WebView2 Runtime
The [WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/?form=MA13LH) is required ([preinstalled onto all Windows 11 devices and eligible Windows 10 devices](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution?tabs=dotnetcsharp)).

## 3. Building & Running

All Flutter code is contained in the `WhatsApp` subfolder.

### 3.1. Install Dependencies
Navigate to the `WhatsApp` folder and fetch the package dependencies:

```powershell
cd WhatsApp
flutter pub get
```

### 3.2. Running in Development Mode
To launch the app with hot reload enabled for debugging:

```powershell
flutter run -d windows
```

### 3.3. Building the Release Executable
To compile a fully optimized release build:

```powershell
flutter build windows
```

## 4. WebView Bridge & Localization Architecture
The application implements a customized bridge to interface with WhatsApp Web. If you are developing or refactoring WebView behavior, keep the following structure in mind:

### 4.1. JavaScript Injection & Overrides (`lib/manager/js_scripts/`)
Scripts injected into the WebView2 instance are organized into modular domain files to keep the main code clean:
- [theme.dart](../WhatsApp/lib/manager/js_scripts/theme.dart): Implements custom dark/light theme CSS injections.
- [notification.dart](../WhatsApp/lib/manager/js_scripts/notification.dart): Injects listeners to intercept web notifications and forward them to the native Windows system.
- [translation.dart](../WhatsApp/lib/manager/js_scripts/translation.dart): Implements page-wide DOM-scanning translations, the hover translate button, and translation bubble renderer. Excludes `contenteditable` nodes to prevent cursor resets while typing.

### 4.2. Type-Safe WebView Communication
All message data sent across WebView JavaScript Channels are serialized as JSON and parsed into structured Dart models at the boundary:
- [webview_payload.dart](../WhatsApp/lib/model/webview_payload.dart): Implements `JsTranslationPayload` and `JsNotificationPayload` with validation checks.
- [webview_bridge_manager.dart](../WhatsApp/lib/manager/webview_bridge_manager.dart): Encapsulates controller creation, channel registrations (`TranslationChannel`, `NotificationChannel`), permission grants, and request routing.

### 4.3. Translation Proxying
- [localization.dart](../WhatsApp/lib/manager/localization.dart): Manages network calls to the Google Translate API endpoint. Translation maps for UI strings are persisted in `translations_cache.json`.

## 5. Portability, Packaging & Publishing

### 5.1. Understanding the Build Output
The release build is generated in the following directory:
`WhatsApp/build/windows/x64/runner/Release/`

### 5.2. Portability Concept
All user settings and active sessions are stored locally in the application folder:
- **Settings**: Saved to `settings.json` in the current working directory.
- **Translations Cache**: Saved to `translations_cache.json` in the current working directory.
- **WebView2 User Profiles**: Saved to `data/webview/EBWebView/WV2Profile_<accountId>` in the current working directory.

This allows the application folder to be moved (e.g., to a USB drive) while fully preserving the user's logged-in accounts and configuration.

### 5.3. Folder Icon Customization (`desktop.ini`)
To give the portable application folder its customized WhatsApp icon, a `desktop.ini` configuration is used:
1. Ensure a copy of the `desktop.ini` file is placed directly in your release distribution folder.
2. Open a terminal and assign the **system** attribute to the `desktop.ini` file:
   ```cmd
   attrib +s desktop.ini
   ```
3. Assign the **system** attribute to the release folder itself. This is critical because Windows ignores `desktop.ini` inside directories unless the directory itself is marked as a system folder:
   ```cmd
   attrib +s "path\to\your\release_folder"
   ```

### 5.4. Publishing Checklist
Before releasing a new version, complete the following steps:
1. **Update Version Numbers**:
   - In the root folder: Update the version string in the [Version](../Version) file.
   - In `WhatsApp/pubspec.yaml`: Update the `version` property.
   - In `WhatsApp/lib/constants.dart`: Update the `appVersion` constant.
2. **Documentation**:
   - Check this file and the [README.md](../README.md) file for any updates to add.
   - Update the [CHANGELOG.md](../CHANGELOG.md) file with the new release notes.
   - Update any screenshots in the documentation.

### 5.5. Creating the Portable Archive
To ensure Windows preserves the system attribute of both the `desktop.ini` file and the release folder, **do not** use the built-in Windows compression utility, as it strips these attributes.
- Use a utility like **7-Zip** or **PeaZip** to compress the release folder.
- Package the contents into an archive named **`WhatsApp.zip`**.

### 5.6. GitHub Release
 - Create the new release, adding the portable archive in the release assets.
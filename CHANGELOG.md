# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

<br /><br />

## [2.4.0] - 2026-07-04
### Added
- Localization & translation
  - Translation of app UI
  - Full page translation (translates WhatsApp UI & chat messages)
  - Translate message hover button
  - Translate all messages button
  - Notification translation
  - Caching list of supported languages & UI text

### Changed
- Hid the "Get WhatsApp for Windows" link at the bottom of the chats list (was visible when logged in and a chat was open)
- Switched to using OS native notifications

### Fixed
- Notifications only shown after restarting the app, after providing permissions
- Profile data not deleted when the profile metadata was manually removed from the `settings.json` file

<br /><br />

## [2.3.0] - 2026-06-20
### Added
- Notification icon for the system tray task
- Update checker

### Changes
- Hid the new "Download Whatsapp for Windows" link in the intro-panel (was visible when logged in and no chat was open)

### Fixed
- Open app window when notification is clicked
- Auto-dismissal of dialogs
- Executable version property incorrectly set
- Theming issues

<br /><br />

## [2.2.0] - 2026-05-12
### Added
- Support for multiple accounts

### Changes
- Moved Theme & DevTools options to the settings dialog

<br /><br />

## [2.1.0] - 2025-04-14
### Fixed
- Theme issues
- Clicking links

<br /><br />

## [2.0.0] - 2024-09-04
### Added
- dark theme
- tray task

### Changes
- web-view implementation swapped out for one with better portability, text highlighting, right click support & scrolling support
- 'X' button on window title-bar now hides the window - to exit the application, use the tray task context menu
- removed refresh button; does not work well with custom styles

### Known Issues
- Occasionally, the theme does not change when the theme button (the light-bulb icon) is clicked 
  - Workaround: <br />
     Exit the app using the tray task and relaunch it. The new theme should be loaded on app startup

<br /><br />

## [1.0.0] - 2024-07-04
Version 1.0.0

[2.4.0]: https://github.com/Faeq-F/whatsappPortable/compare/Version2.3.0...Version2.4.0
[2.3.0]: https://github.com/Faeq-F/whatsappPortable/compare/Version2.2.0...Version2.3.0
[2.2.0]: https://github.com/Faeq-F/whatsappPortable/compare/Version2.1.0...Version2.2.0
[2.1.0]: https://github.com/Faeq-F/whatsappPortable/compare/Version2.0.0...Version2.1.0
[2.0.0]: https://github.com/Faeq-F/whatsappPortable/compare/Version1.0.0...Version2.0.0
[1.0.0]: https://github.com/Faeq-F/whatsappPortable/tree/Version1.0.0
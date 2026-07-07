import { defineStore } from "pinia";

export const useThemesStore = defineStore("themesStore", {
  state: () => ({
    themes: [
      { 
        name: "Light mode", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-Light.png" 
      },
      { 
        name: "Dark mode", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-Dark.png" 
      },
      { 
        name: "Logging in", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-Login.png" 
      },
      { 
        name: "Intro Panel", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-IntroPanel.png" 
      },
      { 
        name: "Settings dialog", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-Settings1.png" 
      },
      { 
        name: "Multiple accounts", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-Settings2-MultipleAccounts.png" 
      },
      { 
        name: "Update check dialog (light mode)", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-UpToDate.png" 
      },
      { 
        name: "Update check dialog (dark mode)", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-UpToDate-Dark.png" 
      },
      { 
        name: "System Tray Task Icon", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-SystemTrayTaskIcon.png" 
      },
      { 
        name: "System Tray Task Notification Icon", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-SystemTrayTask-NotificationIcon.png" 
      },
      { 
        name: "System Tray Task Context Menu", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-SystemTrayTask-ContextMenu.png" 
      },
      { 
        name: "OS native notification", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-OS-NativeNotification.png" 
      },
      { 
        name: "Translated app UI", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-TranslatedAppUI.png" 
      },
      { 
        name: "Entire page translation - intro panel", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-TranslateEntirePage-IntroPanel.png" 
      },
      { 
        name: "Entire page translation - open chat", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-TranslateEntirePage-OpenChat.png" 
      },
      { 
        name: "Translate All Messages", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-TranslateAllMessages.png" 
      },
      { 
        name: "Translate Message Button", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-TranslateMessageButton.png" 
      },
      { 
        name: "Notification with translated content", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-NotificationTranslatedContent.png" 
      },
      { 
        name: "Notification with translate button", 
        image: "https://raw.githubusercontent.com/Faeq-F/whatsappPortable/refs/heads/main/docs/WhatsAppPortable-NotificationTranslateButton.png" 
      },
    ]
  }),
  actions: {
    getGalleryItems() {
      return this.themes.map((t) => t.image);
    }
  },
});

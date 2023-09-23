Clear-Host
Write-Host " ===== Run a Settings App ====="
Write-Host
function Show-Menu {
   Write-Host " Enter 'A' for Accessibility settings."
   Write-Host " Enter 'B' for Apps settings."
   Write-Host " Enter 'O' for Audio settings."
   Write-Host " Enter 'C' for Customisation settings."
   Write-Host
   Write-Host " Enter 'D' for Device settings."
   Write-Host " Enter 'I' for Display settings."
   Write-Host " Enter 'N' for Network settings."
   Write-Host " Enter 'P' for Power settings."
   Write-Host " Enter 'V' for Privacy settings."
   Write-Host
   Write-Host " Enter 'R' for Region and Language settings."
   Write-Host " Enter 'S' for Search settings."
   Write-Host " Enter 'U' for Security settings."
   Write-Host " Enter 'T' for Storage settings."
   Write-Host " Enter 'W' for Windows settings."
   Write-Host
}

function Show-Accessibility {
   Clear-Host
   Write-Host " Enter 1 for Ease of Access Audio"
   Write-Host " Enter 2 for Closed Captioning"
   Write-Host " Enter 3 for Color Filters"
   Write-Host " Enter 4 for Adaptive Color Filter"
   Write-Host " Enter 5 for Text Cursor"
   Write-Host " Enter 6 for Mouse Pointer"
   Write-Host " Enter 7 for Display Text scaling"
   Write-Host " Enter 8 for Eye Control"
   Write-Host " Enter 9 for High Contrast"
   Write-Host " Enter 10 for Magnifier"
   Write-Host " Enter 11 for Mouse"
   Write-Host " Enter 12 for Mouse Pointer"
   Write-Host " Enter 13 for Other options"
   Write-Host " Enter 14 for Speech recognition"
   Write-Host " Enter 15 for Typing"
}

function Show-Apps {
   Clear-Host
   Write-Host " Enter 1 for Apps & features"
   Write-Host " Enter 2 for Apps for websites"
   Write-Host " Enter 3 for AutoPlay"
   Write-Host " Enter 4 for Clipboard"
   Write-Host " Enter 5 for Default apps"
   Write-Host " Enter 6 for Developers"
   Write-Host " Enter 7 for Offline Maps"
   Write-Host " Enter 8 for Download maps"
   Write-Host " Enter 9 for Optional features"
   Write-Host " Enter 10 for Automatic online file downloads"
   Write-Host " Enter 11 for Background apps"
   Write-Host " Enter 12 for Focus assist"
   Write-Host " Enter 13 for Taskbar"
   Write-Host " Enter 14 for Software Center"
}

function Show-Audio {
   Clear-Host
   Write-Host " Enter 1 for App volume and device preferences"
   Write-Host " Enter 2 for Narrator"
   Write-Host " Enter 3 for Start Narrator after sign-in"
   Write-Host " Enter 4 for Sound"
   Write-Host " Enter 5 for Manage sound devices"
   Write-Host " Enter 6 for Speech"
}

function Show-Custom {
   Clear-Host
   Write-Host " Enter 1 for Fonts"
   Write-Host " Enter 2 for Night light settings"
   Write-Host " Enter 3 for Notifications and Actions"
   Write-Host " Enter 4 for Personalization"
   Write-Host " Enter 5 for Backgrounds"
   Write-Host " Enter 6 for Colors"
   Write-Host " Enter 7 for Start Menu"
   Write-Host " Enter 8 for Start Menu (choose which folders appear)"
   Write-Host " Enter 9 for Startup"
   Write-Host " Enter 10 for Tablet mode"
   Write-Host " Enter 11 for Themes"
}

function Show-Devices {
   Clear-Host
   Write-Host " Enter 1 for Touchpad"
   Write-Host " Enter 2 for Keyboard"
   Write-Host " Enter 3 for Mouse & Touchpad Devices"
   Write-Host " Enter 4 for Printers"
   Write-Host " Enter 5 for USB"
}

function Show-Display {
   Clear-Host
   Write-Host " Enter 1 for Connect to a wireless display"
   Write-Host " Enter 2 for Display"
   Write-Host " Enter 3 for Graphics Advanced scaling settings"
   Write-Host " Enter 4 for Graphics performance preference"
   Write-Host " Enter 5 for Multitasking"
   Write-Host " Enter 6 for Projecting to this PC"
   Write-Host " Enter 7 for Display Screen rotation"
   Write-Host " Enter 8 for Video playback"
}

function Show-Network {
   Clear-Host
   Write-Host " Enter 1 for Bluetooth & Connected Devices"
   Write-Host " Enter 2 for Shared experiences"
   Write-Host " Enter 3 for Network & Internet"
   Write-Host " Enter 4 for Airplane mode"
   Write-Host " Enter 5 for Cellular Network"
   Write-Host " Enter 6 for DirectAccess"
   Write-Host " Enter 7 for Ethernet Network"
   Write-Host " Enter 8 for Mobile Hotspot"
   Write-Host " Enter 9 for Proxy (Network)"
   Write-Host " Enter 10 for Network Status"
   Write-Host " Enter 11 for VPN"
   Write-Host " Enter 12 for Wi-Fi"
   Write-Host " Enter 13 for Manage known Wi-Fi"
   Write-Host " Enter 14 for Airplane mode (wireless/bluetooth)"
   Write-Host " Enter 15 for Remote Desktop"
   Write-Host " Enter 16 for Sync your settings"
   Write-Host " Enter 17 for Access work or school"
}
function Show-Power {
   Clear-Host
   Write-Host " Enter 1 for Battery Saver"
   Write-Host " Enter 2 for Battery Saver - settings"
   Write-Host " Enter 3 for Battery Saver - usage"
   Write-Host " Enter 4 for Power & Sleep"
}

function Show-Privacy {
   Clear-Host
   Write-Host " Enter 1 for Privacy"
   Write-Host " Enter 2 for Account info (share between apps)"
   Write-Host " Enter 3 for Activity history"
   Write-Host " Enter 4 for App diagnostics (share between apps)"
   Write-Host " Enter 5 for File System (share between apps)"
   Write-Host " Enter 6 for Document Library (share between apps)"
   Write-Host " Enter 7 for Email (share between apps)"
   Write-Host " Enter 8 for Location (share between apps)"
   Write-Host " Enter 9 for Messaging (share between apps)"
   Write-Host " Enter 10 for Microphone (share between apps)"
   Write-Host " Enter 11 for Motion (share between apps)"
   Write-Host " Enter 12 for Notifications (share between apps)"
   Write-Host " Enter 13 for Online Speech recognition"
   Write-Host " Enter 14 for Tasks (share between apps)"
   Write-Host " Enter 15 for Video Library (share between apps)"
   Write-Host " Enter 16 for Voice activation (apps can listen)"
   Write-Host " Enter 17 for Webcam (share between apps)"
}

function Show-Region {
   Clear-Host
   Write-Host " Enter 1 for Date & Time"
   Write-Host " Enter 2 for Region"
   Write-Host " Enter 3 for Language"
}

function Show-Search {
   Clear-Host
   Write-Host " Enter 1 for Cortana"
   Write-Host " Enter 2 for Cortana permissions"
   Write-Host " Enter 3 for Cortana more detail"
   Write-Host " Enter 4 for Windows Search"
   Write-Host " Enter 5 for Search details"
   Write-Host " Enter 6 for Search Permissions & search history"
}

function Show-Security {
   Clear-Host
   Write-Host " Enter 1 for Activation"
   Write-Host " Enter 2 for Device Encryption"
   Write-Host " Enter 3 for Email & app accounts"
   Write-Host " Enter 4 for Family & other users"
   Write-Host " Enter 5 for Find My Device"
   Write-Host " Enter 6 for Lock screen"
   Write-Host " Enter 7 for Family & other users"
   Write-Host " Enter 8 for Feedback & diagnostics (privacy)"
   Write-Host " Enter 9 for Sign-in options"
   Write-Host " Enter 10 for Dynamic Lock"
   Write-Host " Enter 11 for Windows Hello face setup"
   Write-Host " Enter 12 for Windows Hello fingerprint setup"
   Write-Host " Enter 13 for Security Key setup"
   Write-Host " Enter 14 for Windows Security (Defender)"
   Write-Host " Enter 15 for Windows Security at a glance"
   Write-Host " Enter 16 for Windows Update"
   Write-Host " Enter 17 for WinUpdate - Check for updates"
   Write-Host " Enter 18 for Your info (Microsoft account)"
}

function Show-Storage {
   Clear-Host
   Write-Host " Enter 1 for Backup"
   Write-Host " Enter 2 for Data Sense"
   Write-Host " Enter 3 for Default Save Locations"
   Write-Host " Enter 4 for Storage Sense configuration"
   Write-Host " Enter 5 for Storage Sense"
}

function Show-Windows {
   Clear-Host
   Write-Host " Enter 1 for Home page for Settings"
   Write-Host " Enter 2 for About (Name/Spec)"
   Write-Host " Enter 3 for Delivery Optimization"
   Write-Host " Enter 4 for Recovery - Reset/Advanced startup"
   Write-Host " Enter 5 for Troubleshoot - Fix Windows Update"
   Write-Host " Enter 6 for Windows Insider Program (beta's)"
}

#  Main  #
Show-Menu
$category = Read-Host "Please make a selection"

switch ($category) {
    'A' {
         Clear-Host
         Show-Accessibility
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:easeofaccess-audio;break}
             '2' {start ms-settings:easeofaccess-closedcaptioning;break}
             '3' {start ms-settings:easeofaccess-colorfilter;break}
             '4' {start ms-settings:easeofaccess-colorfilter-adaptivecolorlink;break}
             '5' {start ms-settings:easeofaccess-cursor;break}
             '6' {start ms-settings:easeofaccess-cursorandpointersize;break}
             '7' {start ms-settings:easeofaccess-display;break}
             '8' {start ms-settings:easeofaccess-eyecontrol;break}
             '9' {start ms-settings:easeofaccess-highcontrast;break}
             '10' {start ms-settings:easeofaccess-magnifier;break}
             '11' {start ms-settings:easeofaccess-mouse;break}
             '12' {start ms-settings:easeofaccess-mousepointer;break}
             '13' {start ms-settings:easeofaccess-otheroptions;break}
             '14' {start ms-settings:easeofaccess-speechrecognition;break}
             '15' {start ms-settings:typing;break}
          }
          break
    } 'B' {
         Clear-Host
         Show-Apps
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:appsfeatures;break}
             '2' {start ms-settings:appsforwebsites;break}
             '3' {start ms-settings:autoplay;break}
             '4' {start ms-settings:clipboard;break}
             '5' {start ms-settings:defaultapps;break}
             '6' {start ms-settings:developers;break}
             '7' {start ms-settings:maps;break}
             '8' {start ms-settings:maps-downloadmaps;break}
             '9' {start ms-settings:optionalfeatures;break}
             '10' {start ms-settings:privacy-automaticfiledownloads;break}
             '11' {start ms-settings:privacy-backgroundapps;break}
             '12' {start ms-settings:quiethours;break}
             '13' {start ms-settings:taskbar;break}
             '14' {start softwarecenter:;break}
          }
          break
    } 'O' {
         Clear-Host
         Show-Audio
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:apps-volume;break}
             '2' {start ms-settings:easeofaccess-narrator;break}
             '3' {start ms-settings:easeofaccess-narrator-isautostartenabled;break}
             '4' {start ms-settings:sound;break}
             '5' {start ms-settings:sound-devices;break}
             '6' {start ms-settings:speech;break}
          }
          break
    } 'C' {
         Clear-Host
         Show-Custom
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:fonts;break}
             '2' {start ms-settings:nightlight;break}
             '3' {start ms-settings:notifications;break}
             '4' {start ms-settings:personalization;break}
             '5' {start ms-settings:personalization-background;break}
             '6' {start ms-settings:personalization-colors;break}
             '7' {start ms-settings:colors;break}
             '8' {start ms-settings:personalization-start;break}
             '9' {start ms-settings:personalization-start-places;break}
             '10' {start ms-settings:tabletmode;break}
             '11' {start ms-settings:themes;break}
          }
          break
    } 'D' {
         Clear-Host
         Show-Devices
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:devices-touchpad;break}
             '2' {start ms-settings:easeofaccess-keyboard;break}
             '3' {start ms-settings:mousetouchpad;break}
             '4' {start ms-settings:printers;break}
             '5' {start ms-settings:usb;break}
          }
          break
    } 'I' {
         Clear-Host
         Show-Display
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings-connectabledevices:devicediscovery;break}
             '2' {start ms-settings:display;break}
             '3' {start ms-settings:display-advanced;break}
             '4' {start ms-settings:display-advancedgraphics;break}
             '5' {start ms-settings:multitasking;break}
             '6' {start ms-settings:project;break}
             '7' {start ms-settings:screenrotation;break}
             '8' {start ms-settings:videoplayback;break}
          }
          break
    } 'N' {
         Clear-Host
         Show-Network
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:bluetooth;break}
             '2' {start ms-settings:crossdevice;break}
             '3' {start ms-settings:network;break}
             '4' {start ms-settings:network-airplanemode;break}
             '5' {start ms-settings:network-cellular;break}
             '6' {start ms-settings:network-directaccess;break}
             '7' {start ms-settings:network-ethernet;break}
             '8' {start ms-settings:network-mobilehotspot;break}
             '9' {start ms-settings:network-proxy;break}
             '10' {start ms-settings:network-status;break}
             '11' {start ms-settings:network-vpn;break}
             '12' {start ms-settings:network-wifi;break}
             '13' {start ms-settings:network-wifisettings;break}
             '14' {start ms-settings:proximity;break}
             '15' {start ms-settings:remotedesktop;break}
             '16' {start ms-settings:sync;break}
             '17' {start ms-settings:workplace;break}
          }
          break
    } 'P' {
         Clear-Host
         Show-Power
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:batterysaver;break}
             '2' {start ms-settings:batterysaver-settings;break}
             '3' {start ms-settings:batterysaver-usagedetails;break}
             '4' {start ms-settings:powersleep;break}
          }
          break
    } 'V' {
         Clear-Host
         Show-Privacy
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:privacy;break}
             '2' {start ms-settings:privacy-accountinfo;break}
             '3' {start ms-settings:privacy-activityhistory;break}
             '4' {start ms-settings:privacy-appdiagnostics;break}
             '5' {start ms-settings:privacy-broadfilesystemaccess;break}
             '6' {start ms-settings:privacy-documents;break}
             '7' {start ms-settings:privacy-email;break}
             '8' {start ms-settings:privacy-location;break}
             '9' {start ms-settings:privacy-messaging;break}
             '10' {start ms-settings:privacy-microphone;break}
             '11' {start ms-settings:privacy-motion;break}
             '12' {start ms-settings:privacy-notifications;break}
             '13' {start ms-settings:privacy-speech;break}
             '14' {start ms-settings:privacy-tasks;break}
             '15' {start ms-settings:privacy-videos;break}
             '16' {start ms-settings:privacy-voiceactivation;break}
             '17' {start ms-settings:privacy-webcam;break}
          }
          break
    } 'R' {
         Clear-Host
         Show-Region
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:dateandtime;break}
             '2' {start ms-settings:regionformatting;break}
             '3' {start ms-settings:regionlanguage;break}
          }
          break
    } 'S' {
         Clear-Host
         Show-Search
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:cortana;break}
             '2' {start ms-settings:cortana-permissions;break}
             '3' {start ms-settings:cortana-moredetails;break}
             '4' {start ms-settings:cortana-windowssearch;break}
             '5' {start ms-settings:search-moredetails;break}
             '6' {start ms-settings:search-permissions;break}
          }
          break
     } 'U' {
         Clear-Host
         Show-Security
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:activation;break}
             '2' {start ms-settings:deviceencryption;break}
             '3' {start ms-settings:emailandaccounts;break}
             '4' {start ms-settings:family-group;break}
             '5' {start ms-settings:findmydevice;break}
             '6' {start ms-settings:lockscreen;break}
             '7' {start ms-settings:otherusers;break}
             '8' {start ms-settings:privacy-feedback;break}
             '9' {start ms-settings:signinoptions;break}
             '10' {start ms-settings:signinoptions-dynamiclock;break}
             '11' {start ms-settings:signinoptions-launchfaceenrollment;break}
             '12' {start ms-settings:signinoptions-launchfingerprintenrollment;break}
             '13' {start ms-settings:signinoptions-launchsecuritykeyenrollment;break}
             '14' {start ms-settings:windowsdefender;break}
             '15' {start windowsdefender:;break}
             '16' {start ms-settings:windowsupdate;break}
             '17' {start ms-settings:windowsupdate-action;break}
             '18' {start ms-settings:yourinfo;break}
             }
          break
    } 'T' {
         Clear-Host
         Show-Storage
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:backup;break}
             '2' {start ms-settings:datausage;break}
             '3' {start ms-settings:savelocations;break}
             '4' {start ms-settings:storagepolicies;break}
             '5' {start ms-settings:storagesense;break}
          }
          break
    } 'w' {
         Clear-Host
         Show-Windows
         $Choice = Read-Host "Enter a number"
         switch ($Choice) {
             '1' {start ms-settings:;break}
             '2' {start ms-settings:about;break}
             '3' {start ms-settings:delivery-optimization;break}
             '4' {start ms-settings:recovery;break}
             '5' {start ms-settings:troubleshoot;break}
             '6' {start ms-settings:windowsinsider;break}
          }
          break
      }
    # Add any addititional top menu options here
}
Clear-Host
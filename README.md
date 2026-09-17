# Quickshell Desktop Bar 🚀

A modern, modular floating status bar for Wayland built with [Quickshell](https://quickshell.outfoxxed.me/) and QtQuick / QML, styled in **Catppuccin Mocha** with glassmorphic elements.

---

## ✨ Features

- **Floating Island Aesthetic**: Translucent capsule design with smooth hover highlights and glowing borders.
- **Launcher Button (`❖`)**: Quick-launcher integration for `krunner` (KDE Plasma).
- **System Monitoring (`󰍛`)**: Real-time RAM utilization tracking and UPower battery status.
- **Clock & Date Widget (``)**: Live time and date formatting with interactive seconds toggle.
- **MPRIS Media Player (`󰎈`)**: Native DBus MPRIS integration with Spotify, browser, and VLC controls (Track title, artist, Play/Pause, Previous/Next).
- **Pipewire Audio (`󰕾`)**: Native Pipewire volume tracking, smooth scroll-to-adjust, and click-to-mute.

---

## 📁 Project Structure

```text
~/.config/quickshell/
├── shell.qml                # Main window definition (PanelWindow, Wayland Layer)
├── theme/
│   ├── qmldir               # Singleton module declaration
│   └── Theme.qml            # Design tokens (Catppuccin Mocha, typography, radii)
└── components/
    ├── qmldir               # Component module declarations
    ├── Pill.qml             # Reusable capsule container with animations
    ├── LauncherButton.qml   # App-launcher trigger
    ├── ClockWidget.qml      # Clock and date widget
    ├── MediaWidget.qml      # MPRIS player widget
    ├── VolumeWidget.qml     # Pipewire volume & mute widget
    └── SysInfoWidget.qml    # RAM & Battery stats
```

---

## 🛠️ Usage

### Run with Live Hot-Reload
```bash
quickshell
```

### Run in Background (Daemon)
```bash
quickshell --daemonize
```

### Stop Running Instance
```bash
pkill -f quickshell
```

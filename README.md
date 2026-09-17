# Quickshell Desktop Bar 🚀

A modern, modular floating status bar for Wayland built with [Quickshell](https://quickshell.outfoxxed.me/) and QtQuick / QML, styled in **Catppuccin Mocha** with glassmorphic elements.

---

## ✨ Features

- **Floating Island Aesthetic**: Translucent capsule design with smooth hover highlights and glowing borders.
- **Multi-Monitor Support**: Native dynamic `Variants` across all connected displays (e.g. dual 1440p monitors).
- **Launcher Button (`❖`)**: Quick-launcher integration for `krunner` (KDE Plasma).
- **High-End Hardware Telemetry**:
  - `󰻠` **CPU**: Multi-core processor utilization in real time.
  - `󰍛` **RAM**: Used memory percentage.
  - `󰢮` **GPU**: NVIDIA RTX 5080 temperature and utilization tracking.
- **Clock & Date Widget (``)**: Live time and date formatting with interactive seconds toggle.
- **MPRIS Media Player (`󰎈`)**: Native DBus MPRIS integration with Spotify, browser, and VLC controls (Track title, artist, Play/Pause, Previous/Next).
- **Microphone Control (`󰍬` / `󰍭`)**: PipeWire source widget for Focusrite Scarlett Solo (click-to-mute, wheel-to-adjust gain).
- **Pipewire Audio (`󰕾`)**: Robust volume tracking with `PwObjectTracker`, smooth scroll-to-adjust, and click-to-mute.

---

## 📁 Project Structure

```text
~/.config/quickshell/
├── shell.qml                # Main window definition (Variants, PanelWindow, Wayland Layer)
├── quickshell.service       # Systemd user service unit for autostart
├── theme/
│   ├── qmldir               # Singleton module declaration
│   └── Theme.qml            # Design tokens (Catppuccin Mocha, typography, radii)
└── components/
    ├── qmldir               # Component module declarations
    ├── Pill.qml             # Reusable capsule container with animations
    ├── LauncherButton.qml   # App-launcher trigger
    ├── ClockWidget.qml      # Clock and date widget
    ├── MediaWidget.qml      # MPRIS player widget
    ├── TrayWidget.qml       # System tray icons widget (StatusNotifierItem)
    ├── VolumeWidget.qml     # Pipewire volume & mute widget with PwObjectTracker
    ├── MicWidget.qml        # Pipewire microphone mute & gain widget
    └── SysInfoWidget.qml    # CPU, RAM & NVIDIA RTX 5080 stats
```

---

## 🛠️ Usage

### Run with Live Hot-Reload
```bash
quickshell
```

### Run as Systemd Service (Recommended)
```bash
systemctl --user start quickshell
systemctl --user status quickshell
```

### Enable Autostart on Login
```bash
systemctl --user enable quickshell.service
```

### Stop Running Instance
```bash
systemctl --user stop quickshell
# or manually:
pkill -f quickshell
```

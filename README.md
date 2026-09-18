# Quickshell Desktop Bar 🚀

A modern, modular floating status bar for Wayland built with [Quickshell](https://quickshell.outfoxxed.me/) and QtQuick / QML, styled in **Catppuccin Mocha** with glassmorphic elements.

---

## ✨ Features

- **Floating Island Aesthetic**: Translucent capsule design with smooth hover highlights, glowing borders, and drop-shadow depth.
- **Multi-Monitor Support**: Native dynamic `Variants` across all connected displays (e.g. dual 1440p monitors).
- **Launcher Button (`❖`)**: 
  - Left-Click: Opens `krunner` (KDE Plasma).
  - Right-Click: Opens the KDE Application Launcher Menu.
- **Power Menu with Safety Confirmation (`󰐥`)**:
  - Two-step confirmation for shutdown and reboot to prevent accidental misclicks.
  - Instant sleep, screen lock, and logout options.
- **High-End Hardware Telemetry (`󰻠` / `󰍛` / `󰢮`)**:
  - Centralized single-instance `SysInfoService` (zero duplicate polling on multi-monitor setups).
  - **CPU**: Intel Core Ultra 7 265K multi-core utilization & real-time core package temperature (`Package id 0`) via sysfs.
  - **RAM**: Memory usage percentage and GB used/total.
  - **GPU**: NVIDIA GeForce RTX 5080 temperature, utilization percentage with animated green progress bar, VRAM used/total, and live power draw (W).
  - Quick-switch power profiles (`power-saver`, `balanced`, `performance`) with mouse wheel or right-click.
- **Interactive Clock, Calendar & Pomodoro Hub (`󰃭` / ``)**:
  - Left-Click: Opens Clock & Pomodoro / Calendar Popup.
  - Middle-Click: Toggles seconds display (`HH:mm:ss` vs `HH:mm`).
  - Right-Click: Toggles active Pomodoro timer session.
  - Interactive calendar with clickable day selection and date banner.
- **Live Weather & 3-Day Forecast (`󰖐`)**:
  - Real-time weather pill beside the clock showing condition icon and temperature (e.g. `󰖐 17°C`).
  - Rich popup with localized condition ("Bedeckt"), feels-like temperature, humidity, wind speed, and 3-day forecast with min/max temperatures.
- **Audio Control Center & 1-Click Presets (`󰕾` / `󰍬`)**:
  - 1-Click Audio Scenario Presets:
    - `🎮 Gaming`: INZONE H9 II Headset + Scarlett Solo Mic 1.
    - `📻 Hi-Fi`: Onkyo TX-NR686 Receiver.
    - `🖥️ Monitor`: DELL S2721DGF HDMI Audio.
  - Output volume slider (up to 150%) and microphone gain slider (up to 100%).
  - Mute toggles for both sink and source.
  - Human-friendly device names and internal stream split filtering.
  - Right-click on microphone widget opens `AudioQuickSelect` directly.
- **Quick Settings & Control Center (`󰍜`)**:
  - Quick toggles for KWin Night Light (blue light filter), Do Not Disturb (DND), and Spectacle screenshot shortcuts (region / fullscreen).
  - Quick launcher shortcuts to KDE System Settings and System Monitor.
- **Quick Notes / Scratchpad (`󰏫`)**:
  - Persistent scratchpad notepad in the status bar with auto-save to `~/.config/quickshell/scratchpad_notes.txt`.
  - 1-click clipboard copy and clear actions.
- **Live Network Telemetry (`󰛳` / `󰖩`)**:
  - Live upload and download throughput speed meters.
  - Network popup showing active interface, link status, local IP with 1-click copy, gateway, and KDE network settings shortcut.
- **MPRIS Media Player (`󰎈`)**:
  - Native DBus MPRIS integration (Spotify, VLC, browser).
  - Live album art thumbnail with fallback icon, track title & artist elision, Play/Pause, Previous/Next.

---

## 📁 Project Structure

```text
~/.config/quickshell/
├── shell.qml                     # Main window definition (Variants, PanelWindow, Wayland Layer)
├── quickshell.service            # Systemd user service unit for autostart
├── scratchpad_notes.txt          # Persistent quick notes storage
├── theme/
│   ├── qmldir                    # Singleton module declaration
│   └── Theme.qml                 # Design tokens (Catppuccin Mocha, typography, radii)
├── services/
│   ├── qmldir                    # Singleton service declarations
│   ├── SysInfoService.qml        # Single-instance CPU, RAM, and GPU telemetry
│   ├── NetworkService.qml        # Live throughput, IP, and gateway telemetry
│   ├── WeatherService.qml        # Weather and 3-day forecast service
│   ├── PowerProfileService.qml   # systemd/powerprofilesctl power profile manager
│   └── PomodoroService.qml       # Pomodoro timer service with system notifications
└── components/
    ├── qmldir                    # Component module declarations
    ├── Pill.qml                  # Reusable capsule container with mouse/wheel/click support
    ├── LauncherButton.qml        # KRunner & app-launcher trigger
    ├── PowerButton.qml           # Power button widget
    ├── PowerMenu.qml             # Power popup with confirmation safeguards
    ├── SysInfoWidget.qml         # Hardware telemetry pill
    ├── PerformancePopup.qml      # Performance profiles & hardware telemetry popup
    ├── ClockWidget.qml           # Clock and date widget with seconds toggle
    ├── ClockPopup.qml            # Calendar & Pomodoro tabbed popup
    ├── WeatherWidget.qml         # Weather status bar pill
    ├── WeatherPopup.qml          # Detailed weather & forecast popup
    ├── NotesWidget.qml           # Quick notes pill
    ├── NotesPopup.qml            # Persistent scratchpad popup
    ├── QuickSettingsWidget.qml   # Control center button
    ├── QuickSettingsPopup.qml    # Night light, DND, screenshot control center
    ├── NetworkWidget.qml         # Live network throughput pill
    ├── NetworkPopup.qml          # IP address, throughput & network popup
    ├── MediaWidget.qml           # MPRIS player widget with album art
    ├── TrayWidget.qml            # System tray icons widget (StatusNotifierItem)
    ├── VolumeWidget.qml          # Pipewire volume & mute widget with PwObjectTracker
    ├── MicWidget.qml             # Pipewire microphone widget with quick select
    └── AudioQuickSelect.qml      # Unified audio control center with 1-click presets
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

### Restart Service
```bash
systemctl --user restart quickshell
```

pragma Singleton
import QtQuick

QtObject {
    // Catppuccin Mocha Palette
    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color surface2: "#585b70"
    
    // Glassmorphism tokens
    readonly property color glassBg: "#d91e1e2e"
    readonly property color glassPill: "#40313244"
    readonly property color glassHover: "#6045475a"
    readonly property color glassBorder: "#26ffffff"
    readonly property color glassBorderHover: "#6689b4fa"

    // Accents
    readonly property color blue: "#89b4fa"
    readonly property color mauve: "#cba6f7"
    readonly property color green: "#a6e3a1"
    readonly property color red: "#f38ba8"
    readonly property color peach: "#fab387"
    readonly property color yellow: "#f9e2af"
    readonly property color lavender: "#b4befe"

    // Text tokens
    readonly property color text: "#cdd6f4"
    readonly property color subtext: "#a6adc8"
    readonly property color overlay: "#6c7086"

    // Typography & Metrics
    readonly property string fontFamily: "Inter"
    readonly property string iconFontFamily: "Symbols Nerd Font"
    readonly property int radiusPill: 18
    readonly property int radiusCard: 14
    readonly property int radiusSm: 8
}

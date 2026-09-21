pragma Singleton
import QtQuick

QtObject {
    id: root

    // Theme preset: "mocha" | "macchiato" | "tokyonight" | "nord"
    property string currentTheme: "mocha"

    function cycleTheme() {
        if (currentTheme === "mocha") currentTheme = "tokyonight";
        else if (currentTheme === "tokyonight") currentTheme = "nord";
        else if (currentTheme === "nord") currentTheme = "macchiato";
        else currentTheme = "mocha";
    }

    // Base colors
    readonly property color base: {
        switch (currentTheme) {
            case "tokyonight": return "#1a1b26";
            case "nord": return "#2e3440";
            case "macchiato": return "#24273a";
            default: return "#1e1e2e";
        }
    }

    readonly property color mantle: {
        switch (currentTheme) {
            case "tokyonight": return "#16161e";
            case "nord": return "#272c36";
            case "macchiato": return "#1e2030";
            default: return "#181825";
        }
    }

    readonly property color crust: {
        switch (currentTheme) {
            case "tokyonight": return "#13141c";
            case "nord": return "#1e222a";
            case "macchiato": return "#181926";
            default: return "#11111b";
        }
    }

    readonly property color surface0: {
        switch (currentTheme) {
            case "tokyonight": return "#24283b";
            case "nord": return "#3b4252";
            case "macchiato": return "#363a4f";
            default: return "#313244";
        }
    }

    readonly property color surface1: {
        switch (currentTheme) {
            case "tokyonight": return "#414868";
            case "nord": return "#434c5e";
            case "macchiato": return "#494d64";
            default: return "#45475a";
        }
    }

    readonly property color surface2: {
        switch (currentTheme) {
            case "tokyonight": return "#565f89";
            case "nord": return "#4c566a";
            case "macchiato": return "#5b6078";
            default: return "#585b70";
        }
    }

    // Glassmorphism tokens
    readonly property color glassBg: Qt.rgba(base.r, base.g, base.b, 0.85)
    readonly property color glassPill: Qt.rgba(surface0.r, surface0.g, surface0.b, 0.28)
    readonly property color glassHover: Qt.rgba(surface1.r, surface1.g, surface1.b, 0.45)
    readonly property color glassBorder: "#26ffffff"
    readonly property color glassBorderHover: Qt.rgba(blue.r, blue.g, blue.b, 0.4)

    // Accents
    readonly property color blue: {
        switch (currentTheme) {
            case "tokyonight": return "#7aa2f7";
            case "nord": return "#81a1c1";
            case "macchiato": return "#8aadf4";
            default: return "#89b4fa";
        }
    }

    readonly property color mauve: {
        switch (currentTheme) {
            case "tokyonight": return "#bb9af7";
            case "nord": return "#b48ead";
            case "macchiato": return "#c6a0f6";
            default: return "#cba6f7";
        }
    }

    readonly property color green: {
        switch (currentTheme) {
            case "tokyonight": return "#9ece6a";
            case "nord": return "#a3be8c";
            case "macchiato": return "#a6da95";
            default: return "#a6e3a1";
        }
    }

    readonly property color red: {
        switch (currentTheme) {
            case "tokyonight": return "#f7768e";
            case "nord": return "#bf616a";
            case "macchiato": return "#ed8796";
            default: return "#f38ba8";
        }
    }

    readonly property color peach: {
        switch (currentTheme) {
            case "tokyonight": return "#ff9e64";
            case "nord": return "#d08770";
            case "macchiato": return "#f5a97f";
            default: return "#fab387";
        }
    }

    readonly property color yellow: {
        switch (currentTheme) {
            case "tokyonight": return "#e0af68";
            case "nord": return "#ebcb8b";
            case "macchiato": return "#eed49f";
            default: return "#f9e2af";
        }
    }

    readonly property color lavender: {
        switch (currentTheme) {
            case "tokyonight": return "#7dcfff";
            case "nord": return "#88c0d0";
            case "macchiato": return "#b7bdf8";
            default: return "#b4befe";
        }
    }

    // Text tokens
    readonly property color text: {
        switch (currentTheme) {
            case "tokyonight": return "#c0caf5";
            case "nord": return "#eceff4";
            case "macchiato": return "#cad3f5";
            default: return "#cdd6f4";
        }
    }

    readonly property color subtext: {
        switch (currentTheme) {
            case "tokyonight": return "#a9b1d6";
            case "nord": return "#e5e9f0";
            case "macchiato": return "#a5adcb";
            default: return "#a6adc8";
        }
    }

    readonly property color overlay: {
        switch (currentTheme) {
            case "tokyonight": return "#787c99";
            case "nord": return "#d8dee9";
            case "macchiato": return "#6e738d";
            default: return "#6c7086";
        }
    }

    // Typography & Metrics
    readonly property string fontFamily: "Inter"
    readonly property string iconFontFamily: "Symbols Nerd Font"
    readonly property int radiusPill: 18
    readonly property int radiusCard: 14
    readonly property int radiusSm: 8
}

pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string location: "Essen"
    property string temp: "..."
    property string feelsLike: "..."
    property string description: "Wird geladen..."
    property string humidity: "..."
    property string wind: "..."
    property string conditionIcon: "󰖐"
    property var forecast: []
    property bool isLoaded: false

    function mapWeatherIcon(desc) {
        const d = (desc || "").toLowerCase();
        if (d.includes("sunny") || d.includes("clear") || d.includes("klar") || d.includes("sonnig")) return "󰖙";
        if (d.includes("partly") || d.includes("teilweise") || d.includes("aufgelockert")) return "󰖕";
        if (d.includes("cloud") || d.includes("overcast") || d.includes("bedeckt") || d.includes("bewölkt")) return "󰖐";
        if (d.includes("thunder") || d.includes("gewitter") || d.includes("storm")) return "󰙾";
        if (d.includes("snow") || d.includes("schnee") || d.includes("blizzard")) return "󰼶";
        if (d.includes("rain") || d.includes("regen") || d.includes("drizzle") || d.includes("shower")) return "󰖗";
        if (d.includes("fog") || d.includes("mist") || d.includes("nebel") || d.includes("haze")) return "󰖑";
        return "󰖐";
    }

    function mapWeatherDescription(desc) {
        const d = (desc || "").trim();
        const lower = d.toLowerCase();
        if (lower.includes("clear") || lower.includes("sunny")) return "Sonnig / Klar";
        if (lower.includes("partly cloudy")) return "Teilweise bewölkt";
        if (lower.includes("overcast")) return "Bedeckt";
        if (lower.includes("cloudy")) return "Bewölkt";
        if (lower.includes("patchy rain")) return "Leichter Regen";
        if (lower.includes("light rain")) return "Leichter Regen";
        if (lower.includes("heavy rain")) return "Starker Regen";
        if (lower.includes("thunder")) return "Gewitter";
        if (lower.includes("snow")) return "Schneefall";
        if (lower.includes("fog") || lower.includes("mist")) return "Nebel";
        return d;
    }

    function getDayLabel(dateStr, index) {
        if (index === 0) return "Heute";
        if (index === 1) return "Morgen";
        if (!dateStr) return "In 2 Tagen";
        const parts = dateStr.split("-");
        if (parts.length === 3) {
            const d = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
            const dayNames = ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"];
            return dayNames[d.getDay()];
        }
        return "In 2 Tagen";
    }

    property var proc: Process {
        id: weatherProc
        command: [
            "curl", "-s", "--max-time", "8",
            "https://wttr.in/?format=j1"
        ]
        running: true

        stdout: StdioCollector {
            onTextChanged: {
                if (!text || text.trim().length === 0) return;
                try {
                    const data = JSON.parse(text);
                    if (data && data.current_condition && data.current_condition.length > 0) {
                        const cur = data.current_condition[0];
                        root.temp = (cur.temp_C || "0") + "°C";
                        root.feelsLike = (cur.FeelsLikeC || "0") + "°C";
                        const rawDesc = (cur.weatherDesc && cur.weatherDesc[0]) ? cur.weatherDesc[0].value : "";
                        root.description = root.mapWeatherDescription(rawDesc);
                        root.conditionIcon = root.mapWeatherIcon(rawDesc);
                        root.humidity = (cur.humidity || "0") + "%";
                        root.wind = (cur.windspeedKmph || "0") + " km/h";

                        if (data.nearest_area && data.nearest_area[0] && data.nearest_area[0].areaName && data.nearest_area[0].areaName[0]) {
                            root.location = data.nearest_area[0].areaName[0].value;
                        }

                        if (data.weather && Array.isArray(data.weather)) {
                            const fList = [];
                            const maxDays = Math.min(3, data.weather.length);
                            for (let i = 0; i < maxDays; i++) {
                                const dayObj = data.weather[i];
                                const rawDayDesc = (dayObj.hourly && dayObj.hourly[4] && dayObj.hourly[4].weatherDesc && dayObj.hourly[4].weatherDesc[0])
                                    ? dayObj.hourly[4].weatherDesc[0].value
                                    : (dayObj.hourly && dayObj.hourly[0] && dayObj.hourly[0].weatherDesc && dayObj.hourly[0].weatherDesc[0]) ? dayObj.hourly[0].weatherDesc[0].value : "";
                                
                                fList.push({
                                    dayLabel: root.getDayLabel(dayObj.date, i),
                                    min: (dayObj.mintempC || "0") + "°",
                                    max: (dayObj.maxtempC || "0") + "°",
                                    icon: root.mapWeatherIcon(rawDayDesc),
                                    desc: root.mapWeatherDescription(rawDayDesc)
                                });
                            }
                            root.forecast = fList;
                        }
                        root.isLoaded = true;
                    }
                } catch (e) {
                    console.log("Weather JSON parse error:", e);
                    if (!root.isLoaded) {
                        root.description = "Dienst nicht erreichbar";
                        root.conditionIcon = "󰖪";
                    }
                }
            }
        }

        onExited: (exitCode) => {
            if (exitCode !== 0 && !root.isLoaded) {
                root.description = "Offline / Kein Wetter";
                root.conditionIcon = "󰖪";
                root.temp = "--";
            }
        }
    }

    function refresh() {
        if (!weatherProc.running) {
            weatherProc.running = true;
        }
    }

    // Fast retry (30s) if offline or failed on boot
    property var retryTimer: Timer {
        interval: 30000
        running: !root.isLoaded
        repeat: true
        onTriggered: root.refresh()
    }

    // Refresh every 20 minutes (1200000 ms) when loaded
    property var pollTimer: Timer {
        interval: 1200000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}

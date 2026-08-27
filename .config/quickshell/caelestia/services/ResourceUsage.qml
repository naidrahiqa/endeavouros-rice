pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia

Singleton {
    id: root

    property real memoryTotal: 1
    property real memoryFree: 0
    property real memoryUsed: memoryTotal - memoryFree
    property real memoryUsedPercentage: memoryUsed / memoryTotal
    property real swapTotal: 1
    property real swapFree: 0
    property real swapUsed: swapTotal - swapFree
    property real swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0
    property real cpuUsage: 0
    property var previousCpuStats

    property real diskTotal: 1
    property real diskUsed: 0
    property real diskFree: 0
    property real diskUsedPercentage: diskTotal > 0 ? diskUsed / diskTotal : 0

    property real cpuTemp: 0

    readonly property int historyLength: 60
    property list<real> cpuUsageHistory: []
    property list<real> memoryUsageHistory: []
    property list<real> swapUsageHistory: []
    property list<real> diskUsageHistory: []

    function kbToGbString(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB"
    }

    function updateHistories() {
        cpuUsageHistory = [...cpuUsageHistory, cpuUsage]
        if (cpuUsageHistory.length > historyLength) cpuUsageHistory.shift()

        memoryUsageHistory = [...memoryUsageHistory, memoryUsedPercentage]
        if (memoryUsageHistory.length > historyLength) memoryUsageHistory.shift()

        swapUsageHistory = [...swapUsageHistory, swapUsedPercentage]
        if (swapUsageHistory.length > historyLength) swapUsageHistory.shift()

        diskUsageHistory = [...diskUsageHistory, diskUsedPercentage]
        if (diskUsageHistory.length > historyLength) diskUsageHistory.shift()
    }

    Process {
        id: tempProc
        command: ["bash", "-c", "sensors 2>/dev/null | grep -E 'Package id 0|Tctl|Tdie' | grep -oP '\\+\\K[0-9.]+(?=°C)' | head -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.cpuTemp = parseFloat(text.trim()) || 0
            }
        }
    }

    Process {
        id: diskProc
        command: ["bash", "-c", "df -k / | awk 'NR==2{print $2,$3,$4}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ").map(Number)
                if (parts.length >= 3) {
                    root.diskTotal = parts[0]
                    root.diskUsed  = parts[1]
                    root.diskFree  = parts[2]
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            tempProc.running = false
            tempProc.running = true
            diskProc.running = false
            diskProc.running = true
        }
    }

    Timer {
        interval: 1
        running: true
        repeat: true
        onTriggered: {
            fileMeminfo.reload()
            fileStat.reload()

            const textMeminfo = fileMeminfo.text()
            memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)?.[1] ?? 1)
            memoryFree  = Number(textMeminfo.match(/MemAvailable: *(\d+)/)?.[1] ?? 0)
            swapTotal   = Number(textMeminfo.match(/SwapTotal: *(\d+)/)?.[1] ?? 1)
            swapFree    = Number(textMeminfo.match(/SwapFree: *(\d+)/)?.[1] ?? 0)

            const textStat = fileStat.text()
            const cpuLine  = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
            if (cpuLine) {
                const stats = cpuLine.slice(1).map(Number)
                const total = stats.reduce((a, b) => a + b, 0)
                const idle  = stats[3]
                if (previousCpuStats) {
                    const totalDiff = total - previousCpuStats.total
                    const idleDiff  = idle  - previousCpuStats.idle
                    cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                }
                previousCpuStats = { total, idle }
            }

            root.updateHistories()
        }
    }

    FileView { id: fileMeminfo; path: "/proc/meminfo" }
    FileView { id: fileStat;    path: "/proc/stat" }

    IpcHandler {
        target: "resources"

        function getUsage(): var {
            return {
                cpu: Math.round(root.cpuUsage * 100),
                memory: Math.round(root.memoryUsedPercentage * 100),
                swap: Math.round(root.swapUsedPercentage * 100),
                disk: Math.round(root.diskUsedPercentage * 100),
                cpuTemp: root.cpuTemp,
                memoryTotal: root.kbToGbString(root.memoryTotal),
                memoryUsed: root.kbToGbString(root.memoryUsed),
                swapTotal: root.kbToGbString(root.swapTotal),
                swapUsed: root.kbToGbString(root.swapUsed),
                diskTotal: root.kbToGbString(root.diskTotal),
                diskUsed: root.kbToGbString(root.diskUsed)
            }
        }
    }
}

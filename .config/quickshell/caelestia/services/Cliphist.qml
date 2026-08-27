pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia

Singleton {
    id: root

    property string cliphistBinary: "cliphist"
    property list<string> entries: []

    function shellEscape(str) {
        return str.replace(/'/g, "'\\''");
    }

    function refresh() {
        readProc.buffer = []
        readProc.running = true
    }

    function copy(entry) {
        Quickshell.execDetached(["bash", "-c", `printf '${shellEscape(entry)}' | ${root.cliphistBinary} decode | wl-copy`]);
    }

    function paste(entry) {
        Quickshell.execDetached(["bash", "-c", `printf '${shellEscape(entry)}' | ${root.cliphistBinary} decode | wl-copy && wl-paste`]);
    }

    function deleteEntry(entry) {
        deleteProc.entry = entry;
        deleteProc.running = true;
    }

    function wipe() {
        root.entries = [];
        wipeProc.running = true;
    }

    Connections {
        target: Quickshell
        function onClipboardTextChanged() {
            delayedUpdateTimer.restart()
        }
    }

    Timer {
        id: delayedUpdateTimer
        interval: 50
        repeat: false
        onTriggered: {
            root.refresh()
        }
    }

    Process {
        id: readProc
        property list<string> buffer: []

        command: [root.cliphistBinary, "list"]

        stdout: SplitParser {
            onRead: (line) => {
                readProc.buffer.push(line)
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.entries = readProc.buffer
            } else {
                root.entries = []
                console.error("[Cliphist] Failed to refresh with code", exitCode)
            }
        }
    }

    Process {
        id: deleteProc
        property string entry: ""
        command: ["bash", "-c", `echo '${shellEscape(deleteProc.entry)}' | ${root.cliphistBinary} delete`]
        onExited: (exitCode, exitStatus) => {
            root.refresh();
        }
    }

    Process {
        id: wipeProc
        command: ["bash", "-c", `${root.cliphistBinary} wipe; rm -rf ~/.cache/cliphist/db`]
        onExited: (exitCode, exitStatus) => {
            root.entries = [];
        }
    }

    IpcHandler {
        target: "cliphist"

        function update(): void {
            root.refresh()
        }

        function copyEntry(entry: string): void {
            root.copy(entry)
        }

        function deleteEntry(entry: string): void {
            root.deleteEntry(entry)
        }

        function wipeAll(): void {
            root.wipe()
        }
    }

    Component.onCompleted: {
        refresh()
    }
}

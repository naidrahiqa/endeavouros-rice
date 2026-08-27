pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia

Singleton {
    id: root

    // Pomodoro settings
    property int focusTime: 1500      // 25 minutes in seconds
    property int breakTime: 300       // 5 minutes
    property int longBreakTime: 900   // 15 minutes
    property int cyclesBeforeLongBreak: 4

    // Pomodoro state
    property bool pomodoroRunning: false
    property bool pomodoroBreak: false
    property bool pomodoroLongBreak: false
    property int pomodoroCycle: 0
    property int pomodoroSecondsLeft: focusTime
    property int pomodoroStartTime: 0

    readonly property int pomodoroLapDuration: pomodoroLongBreak ? longBreakTime : pomodoroBreak ? breakTime : focusTime

    // Stopwatch state
    property bool stopwatchRunning: false
    property int stopwatchTime: 0
    property int stopwatchStartTime: 0
    property var stopwatchLaps: []

    function getCurrentTimeInSeconds() {
        return Math.floor(Date.now() / 1000);
    }

    function getCurrentTimeIn10ms() {
        return Math.floor(Date.now() / 10);
    }

    // Pomodoro functions
    function togglePomodoro() {
        pomodoroRunning = !pomodoroRunning;
        if (pomodoroRunning) {
            pomodoroStartTime = getCurrentTimeInSeconds() + pomodoroSecondsLeft - pomodoroLapDuration;
        }
    }

    function resetPomodoro() {
        pomodoroRunning = false;
        pomodoroBreak = false;
        pomodoroLongBreak = false;
        pomodoroStartTime = getCurrentTimeInSeconds();
        pomodoroCycle = 0;
        pomodoroSecondsLeft = focusTime;
    }

    function refreshPomodoro() {
        if (getCurrentTimeInSeconds() >= pomodoroStartTime + pomodoroLapDuration) {
            pomodoroBreak = !pomodoroBreak;
            pomodoroStartTime = getCurrentTimeInSeconds();

            if (!pomodoroBreak) {
                pomodoroCycle = (pomodoroCycle + 1) % cyclesBeforeLongBreak;
            }
            pomodoroLongBreak = pomodoroBreak && (pomodoroCycle + 1 == cyclesBeforeLongBreak);

            let notificationMessage;
            if (pomodoroLongBreak) {
                notificationMessage = `Long break: ${Math.floor(longBreakTime / 60)} minutes`;
            } else if (pomodoroBreak) {
                notificationMessage = `Break: ${Math.floor(breakTime / 60)} minutes`;
            } else {
                notificationMessage = `Focus: ${Math.floor(focusTime / 60)} minutes`;
            }

            Quickshell.execDetached(["notify-send", "Pomodoro", notificationMessage, "-a", "Shell"]);
        }

        pomodoroSecondsLeft = pomodoroLapDuration - (getCurrentTimeInSeconds() - pomodoroStartTime);
    }

    Timer {
        id: pomodoroTimer
        interval: 200
        running: root.pomodoroRunning
        repeat: true
        onTriggered: refreshPomodoro()
    }

    // Stopwatch functions
    function toggleStopwatch() {
        if (stopwatchRunning)
            stopwatchPause();
        else
            stopwatchResume();
    }

    function stopwatchPause() {
        stopwatchRunning = false;
    }

    function stopwatchResume() {
        if (stopwatchTime === 0) stopwatchLaps = [];
        stopwatchRunning = true;
        stopwatchStartTime = getCurrentTimeIn10ms() - stopwatchTime;
    }

    function stopwatchReset() {
        stopwatchTime = 0;
        stopwatchLaps = [];
        stopwatchRunning = false;
    }

    function stopwatchRecordLap() {
        stopwatchLaps.push(stopwatchTime);
    }

    function refreshStopwatch() {
        stopwatchTime = getCurrentTimeIn10ms() - stopwatchStartTime;
    }

    Timer {
        id: stopwatchTimer
        interval: 10
        running: root.stopwatchRunning
        repeat: true
        onTriggered: refreshStopwatch()
    }

    IpcHandler {
        target: "timer"

        function togglePomodoroCmd(): void {
            root.togglePomodoro()
        }

        function resetPomodoroCmd(): void {
            root.resetPomodoro()
        }

        function toggleStopwatchCmd(): void {
            root.toggleStopwatch()
        }

        function resetStopwatchCmd(): void {
            root.stopwatchReset()
        }

        function lapStopwatchCmd(): void {
            root.stopwatchRecordLap()
        }

        function getStatus(): var {
            return {
                pomodoro: {
                    running: root.pomodoroRunning,
                    isBreak: root.pomodoroBreak,
                    secondsLeft: root.pomodoroSecondsLeft,
                    cycle: root.pomodoroCycle
                },
                stopwatch: {
                    running: root.stopwatchRunning,
                    time: root.stopwatchTime
                }
            }
        }
    }

    Component.onCompleted: {
        if (!stopwatchRunning)
            stopwatchReset();
    }
}

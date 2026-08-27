import QtQuick
import Quickshell
import Caelestia.Config
import qs.services

Scope {
    Component.onCompleted: {
        // Force certain singletons to load on shell init instead of lazily

        IdleInhibitor;
        GameMode;
        Notifs;
        Players;
        Brightness;
        Weather.reload();

        // New services from end4-pC integration
        Cliphist;
        TrayService;
        Todo;
        TimerService;
        ResourceUsage;

        if (GlobalConfig.utilities.vpn.enabled)
            VPN;
    }
}

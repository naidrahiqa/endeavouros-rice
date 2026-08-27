pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Caelestia
import Caelestia.Config

Singleton {
    id: root

    property bool filterPassive: GlobalConfig.tray?.filterPassive ?? true
    property list<var> items: SystemTray.items.values.filter(i => !filterPassive || i.status !== SystemTrayItem.Passive)

    function getTooltipForItem(item) {
        var result = item.tooltipTitle.length > 0 ? item.tooltipTitle
                : (item.title.length > 0 ? item.title : item.id);
        if (item.tooltipDescription.length > 0) result += " • " + item.tooltipDescription;
        return result;
    }

    function activateItem(item) {
        item.activate();
    }

    function secondaryItem(item) {
        item.secondaryActivate();
    }
}

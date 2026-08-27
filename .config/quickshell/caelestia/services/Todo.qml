pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia

Singleton {
    id: root

    property var list: []
    property string filePath: `${Paths.state}/todo.json`

    function addTask(desc) {
        const item = {
            "content": desc,
            "done": false,
        }
        list.push(item)
        root.list = list.slice(0)
        save()
    }

    function markDone(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = true
            root.list = list.slice(0)
            save()
        }
    }

    function markUnfinished(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = false
            root.list = list.slice(0)
            save()
        }
    }

    function deleteItem(index) {
        if (index >= 0 && index < list.length) {
            list.splice(index, 1)
            root.list = list.slice(0)
            save()
        }
    }

    function save() {
        todoFile.setText(JSON.stringify(root.list))
    }

    function refresh() {
        todoFile.reload()
    }

    FileView {
        id: todoFile
        path: root.filePath
        onLoaded: {
            const content = todoFile.text()
            root.list = JSON.parse(content)
            console.log("[Todo] Loaded", root.list.length, "items")
        }
        onLoadFailed: (error) => {
            if (error == FileViewError.FileNotFound) {
                console.log("[Todo] File not found, creating new file.")
                root.list = []
                todoFile.setText(JSON.stringify(root.list))
            } else {
                console.log("[Todo] Error loading file:", error)
            }
        }
    }

    Component.onCompleted: {
        refresh()
    }

    IpcHandler {
        target: "todo"

        function add(task: string): void {
            root.addTask(task)
        }

        function list(): var {
            return root.list
        }

        function done(index: int): void {
            root.markDone(index)
        }

        function remove(index: int): void {
            root.deleteItem(index)
        }
    }
}

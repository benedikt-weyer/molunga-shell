pragma Singleton
import Quickshell
import Quickshell.Io
import QtQml

// VPN connections, via `nmcli` rather than Quickshell.Networking (which
// only models devices/wifi/wired - NetworkManager's VPN connection
// profiles aren't part of that module). Polled rather than event-driven,
// since nmcli has no "watch" mode worth shelling out to; every 5s is
// frequent enough for a status icon.
Singleton {
    id: root

    property var connections: []
    property bool available: false

    readonly property bool anyActive: connections.some(c => c.active)

    function connect(name) {
        Quickshell.execDetached(["nmcli", "con", "up", "id", name]);
        refreshSoon.start();
    }

    function disconnect(name) {
        Quickshell.execDetached(["nmcli", "con", "down", "id", name]);
        refreshSoon.start();
    }

    function refresh() {
        if (!lister.running) lister.running = true;
    }

    Process {
        id: lister
        command: ["nmcli", "-t", "-f", "NAME,TYPE,STATE", "con", "show"]

        stdout: StdioCollector {
            id: collector
            onStreamFinished: {
                root.available = true;
                root.connections = collector.text
                    .split("\n")
                    .map(line => line.trim())
                    .filter(line => line.length > 0)
                    .map(line => line.split(":"))
                    .filter(fields => fields.length >= 3 && /vpn|wireguard/i.test(fields[1]))
                    .map(fields => ({ name: fields[0], active: fields[2] === "activated" }));
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.available = false;
                root.connections = [];
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // A one-shot delayed refresh after connect()/disconnect(), since nmcli
    // returns as soon as the request is *accepted*, not once the state
    // change actually lands.
    Timer {
        id: refreshSoon
        interval: 1500
        onTriggered: root.refresh()
    }
}

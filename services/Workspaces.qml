pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Bridges ironland-copositor's per-output workspace state (the
// `ext-workspace-v1` global it implements) into the shell, via the
// `ironland-workspaces` helper binary shipped alongside the compositor -
// Quickshell has no built-in support for that protocol to talk to it
// directly. See that binary's own module doc for the wire format this
// mirrors.
//
// `outputs` is `[{name, workspaces: [{index, name, active}]}]`, refreshed
// every time the helper reports a change.
Singleton {
    id: root

    property var outputs: []
    property bool available: false

    function forOutput(name) {
        for (const o of root.outputs) {
            if (o.name === name) return o.workspaces;
        }
        return [];
    }

    function activate(output, index) {
        if (!proc.running) return;
        proc.write(JSON.stringify({ activate: { output: output, index: index } }) + "\n");
    }

    Process {
        id: proc
        command: ["ironland-workspaces"]
        running: true
        stdinEnabled: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const line = data.trim();
                if (!line) return;
                try {
                    const parsed = JSON.parse(line);
                    root.outputs = parsed.outputs || [];
                    root.available = true;
                } catch (e) {
                    console.warn("Workspaces: ignoring malformed line from ironland-workspaces:", line);
                }
            }
        }

        // Otherwise a failure past startup (e.g. "compositor doesn't
        // support ext-workspace-v1") is thrown away silently - the
        // indicator still falls back to "workspaces unavailable" via
        // `onExited` below, but with nothing in the logs explaining why.
        stderr: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const line = data.trim();
                if (line) console.warn("Workspaces: ironland-workspaces:", line);
            }
        }

        onExited: (exitCode, exitStatus) => {
            console.warn("Workspaces: ironland-workspaces exited (code", exitCode, ", status", exitStatus, ") - retrying in 3s");
            root.available = false;
            root.outputs = [];
            restartTimer.start();
        }
    }

    // A dead compositor connection or output hotplug (see this helper's own
    // "known limitation" doc comment: it only binds outputs present at
    // startup) leaves `proc` exited with nothing to bring it back - retry
    // instead of leaving the indicator permanently stuck on "unavailable".
    Timer {
        id: restartTimer
        interval: 3000
        onTriggered: proc.running = true
    }
}

pragma Singleton
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

        onExited: (exitCode, exitStatus) => {
            root.available = false;
            root.outputs = [];
        }
    }
}

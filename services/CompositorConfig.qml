pragma Singleton
import Quickshell
import Quickshell.Io

// Reads and edits ironland-compositor's own config.toml (see that repo's
// `src/config.rs` for the authoritative schema) for the settings page.
//
// This is a line-based patcher, not a real TOML parser: it only knows how
// to read/replace the handful of scalar keys the settings page exposes
// (top-level, and inside `[workspaces]`), and leaves everything else in the
// file - comments, `[shortcuts]`, `[outputs.*]` - untouched. Good enough for
// a settings UI that only ever touches its own known fields; anything more
// general would need an actual TOML parser, which isn't available in QML.
Singleton {
    id: root

    readonly property string path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/ironland-compositor/config.toml"

    property bool loaded: false
    property string terminal: "weston-terminal"
    property string browser: "brave"
    property string fileManager: "iron-file"
    property bool topBar: false
    property string workspaceMode: "per_monitor"
    property int workspaceCount: 4
    property bool workspaceDynamic: false
    property bool workspaceOverlay: true

    function reload() {
        file.reload();
    }

    function save() {
        let text = file.text();

        text = upsertTopLevel(text, "terminal", quote(root.terminal));
        text = upsertTopLevel(text, "browser", quote(root.browser));
        text = upsertTopLevel(text, "file_manager", quote(root.fileManager));
        text = upsertTopLevel(text, "top_bar", root.topBar ? "true" : "false");

        text = upsertSection(text, "workspaces", [
            ["mode", quote(root.workspaceMode)],
            ["count", String(Math.max(1, root.workspaceCount))],
            ["dynamic", root.workspaceDynamic ? "true" : "false"],
            ["overlay", root.workspaceOverlay ? "true" : "false"],
        ]);

        file.setText(text);
    }

    function quote(s) {
        return "\"" + String(s).replace(/\\/g, "\\\\").replace(/"/g, "\\\"") + "\"";
    }

    function parse(text) {
        root.terminal = extractTopLevelString(text, "terminal", root.terminal);
        root.browser = extractTopLevelString(text, "browser", root.browser);
        root.fileManager = extractTopLevelString(text, "file_manager", root.fileManager);
        root.topBar = extractTopLevelBool(text, "top_bar", root.topBar);

        const section = extractSection(text, "workspaces");
        root.workspaceMode = extractString(section, "mode", root.workspaceMode);
        root.workspaceCount = extractInt(section, "count", root.workspaceCount);
        root.workspaceDynamic = extractBool(section, "dynamic", root.workspaceDynamic);
        root.workspaceOverlay = extractBool(section, "overlay", root.workspaceOverlay);

        root.loaded = true;
    }

    // --- extraction helpers -------------------------------------------

    function extractTopLevelString(text, key, fallback) {
        return extractString(text, key, fallback);
    }

    function extractTopLevelBool(text, key, fallback) {
        return extractBool(text, key, fallback);
    }

    function extractString(text, key, fallback) {
        const m = text.match(new RegExp("(?:^|\\n)\\s*" + key + "\\s*=\\s*\"([^\"]*)\""));
        return m ? m[1] : fallback;
    }

    function extractBool(text, key, fallback) {
        const m = text.match(new RegExp("(?:^|\\n)\\s*" + key + "\\s*=\\s*(true|false)"));
        return m ? m[1] === "true" : fallback;
    }

    function extractInt(text, key, fallback) {
        const m = text.match(new RegExp("(?:^|\\n)\\s*" + key + "\\s*=\\s*(\\d+)"));
        return m ? parseInt(m[1], 10) : fallback;
    }

    function extractSection(text, header) {
        const idx = text.indexOf("[" + header + "]");
        if (idx === -1) return "";
        const rest = text.slice(idx + header.length + 2);
        const next = rest.search(/\n\[/);
        return next === -1 ? rest : rest.slice(0, next);
    }

    // --- patch helpers ---------------------------------------------------

    function upsertTopLevel(text, key, literal) {
        const re = new RegExp("(^|\\n)(" + key + "\\s*=).*");
        if (re.test(text)) {
            return text.replace(re, (m, p1, p2) => p1 + p2 + " " + literal);
        }
        const firstSection = text.search(/^\[/m);
        const line = key + " = " + literal + "\n";
        if (firstSection === -1) {
            return text.length && !text.endsWith("\n") ? text + "\n" + line : text + line;
        }
        return text.slice(0, firstSection) + line + text.slice(firstSection);
    }

    function upsertSection(text, header, keyValues) {
        const headerLine = "[" + header + "]";
        const idx = text.indexOf(headerLine);
        if (idx === -1) {
            let block = (text.length && !text.endsWith("\n") ? "\n\n" : "\n") + headerLine + "\n";
            for (const [k, v] of keyValues) block += k + " = " + v + "\n";
            return text + block;
        }
        const bodyStart = idx + headerLine.length;
        const rest = text.slice(bodyStart);
        const nextIdx = rest.search(/\n\[/);
        const bodyEnd = nextIdx === -1 ? text.length : bodyStart + nextIdx + 1;
        let body = text.slice(bodyStart, bodyEnd);
        for (const [k, v] of keyValues) {
            const re = new RegExp("(^|\\n)(" + k + "\\s*=).*");
            if (re.test(body)) {
                body = body.replace(re, (m, p1, p2) => p1 + p2 + " " + v);
            } else {
                body += k + " = " + v + "\n";
            }
        }
        return text.slice(0, bodyStart) + body + text.slice(bodyEnd);
    }

    FileView {
        id: file
        path: root.path
        watchChanges: true
        printErrors: false
        onLoaded: root.parse(file.text())
        onLoadFailed: error => {
            // Missing file just means "using compositor defaults" - parse
            // an empty string so the properties above keep their built-in
            // fallbacks, and `save()` will create the file on first write.
            root.parse("");
        }
        onFileChanged: reload()
    }
}

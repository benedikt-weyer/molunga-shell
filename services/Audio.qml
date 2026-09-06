pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

// Shared PipeWire state for the bar indicator and sound settings panel.
Singleton {
    id: root

    readonly property bool ready: Pipewire.ready
    readonly property var outputDevice: Pipewire.defaultAudioSink
    readonly property var inputDevice: Pipewire.defaultAudioSource

    readonly property var outputDevices: Pipewire.nodes.values.filter(node =>
        node.audio !== null && node.isSink && !node.isStream)
    readonly property var inputDevices: Pipewire.nodes.values.filter(node =>
        node.audio !== null && !node.isSink && !node.isStream && !node.name.endsWith(".monitor"))

    readonly property real outputVolume: outputDevice?.audio.volume ?? 0
    readonly property real inputVolume: inputDevice?.audio.volume ?? 0
    readonly property bool outputMuted: outputDevice?.audio.muted ?? false
    readonly property bool inputMuted: inputDevice?.audio.muted ?? false

    // Volume and mute properties are only valid on explicitly bound nodes.
    PwObjectTracker {
        objects: [root.outputDevice, root.inputDevice]
    }

    function label(node) {
        if (!node) return "No device";
        return node.description || node.nickname || node.name;
    }

    function selectOutput(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function selectInput(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }

    function setOutputVolume(value) {
        if (outputDevice?.audio) outputDevice.audio.volume = Math.max(0, Math.min(1.5, value));
    }

    function setInputVolume(value) {
        if (inputDevice?.audio) inputDevice.audio.volume = Math.max(0, Math.min(1.5, value));
    }

    function toggleOutputMute() {
        if (outputDevice?.audio) outputDevice.audio.muted = !outputDevice.audio.muted;
    }

    function toggleInputMute() {
        if (inputDevice?.audio) inputDevice.audio.muted = !inputDevice.audio.muted;
    }
}

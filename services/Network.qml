pragma Singleton
import Quickshell
import Quickshell.Networking

// Thin projection over Quickshell's own NetworkManager-backed
// Quickshell.Networking module - unlike workspaces, this needs no bridging
// of our own, since it's compositor-agnostic (talks to NetworkManager over
// D-Bus, not to ironland-compositor).
Singleton {
    id: root

    readonly property var devices: Networking.devices ? Networking.devices.values : []
    readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) || null
    readonly property var wiredDevice: devices.find(d => d.type === DeviceType.Wired) || null

    readonly property bool wifiSupported: wifiDevice !== null
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property var wifiNetworks: wifiDevice ? wifiDevice.networks.values : []
    readonly property var activeWifiNetwork: wifiNetworks.find(n => n.connected) || null

    readonly property bool wiredSupported: wiredDevice !== null
    readonly property bool wiredConnected: wiredDevice ? wiredDevice.connected : false
    readonly property string wiredName: wiredDevice ? wiredDevice.name : ""

    function setWifiEnabled(enabled) {
        Networking.wifiEnabled = enabled;
    }

    function connect(network) {
        network.connect();
    }

    function connectWithPsk(network, psk) {
        network.connectWithPsk(psk);
    }

    function disconnect(network) {
        network.disconnect();
    }

    function forget(network) {
        network.forget();
    }

    function signalBars(network) {
        const s = network ? network.signalStrength : 0;
        if (s >= 80) return 4;
        if (s >= 55) return 3;
        if (s >= 30) return 2;
        if (s > 0) return 1;
        return 0;
    }

    function isSecured(network) {
        return network && network.security !== WifiSecurityType.Open;
    }
}

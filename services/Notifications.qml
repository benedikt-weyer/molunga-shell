pragma Singleton
import QtQml
import Quickshell
import Quickshell.Services.Notifications

// Owns the notification daemon (org.freedesktop.Notifications) and keeps
// two lists derived from it:
//  - `active`: unread toasts, shown by NotificationPopups and cleared once
//    their timeout fires or the user dismisses them.
//  - `history`: everything received this session, newest first, shown by
//    NotificationMenu. Capped at `historyLimit` so it can't grow forever.
Singleton {
    id: root

    readonly property int historyLimit: 100
    readonly property int defaultTimeoutMs: 6000

    property var active: []
    property var history: []

    function dismiss(entry) {
        root.active = root.active.filter(e => e !== entry);
        if (entry.wrapped) entry.wrapped.dismiss();
    }

    function clearHistory() {
        root.history = [];
    }

    NotificationServer {
        id: server
        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: false
        persistenceSupported: false
        inlineReplySupported: false

        onNotification: notification => {
            notification.tracked = true;

            const entry = {
                key: notification.id + ":" + Date.now(),
                appName: notification.appName || "",
                summary: notification.summary || "",
                body: notification.body || "",
                image: notification.image || "",
                appIcon: notification.appIcon || "",
                urgency: notification.urgency,
                time: new Date(),
                actions: (notification.actions || []).map(a => ({ id: a.identifier, text: a.text, wrapped: a })),
                wrapped: notification,
            };

            root.active = [entry, ...root.active];
            root.history = [entry, ...root.history].slice(0, root.historyLimit);

            notification.closed.connect(() => {
                root.active = root.active.filter(e => e !== entry);
            });

            if (notification.urgency !== NotificationUrgency.Critical) {
                const timer = timeoutComponent.createObject(root, { target: entry });
                timer.start();
            }
        }
    }

    Component {
        id: timeoutComponent
        Timer {
            property var target
            interval: root.defaultTimeoutMs
            running: false
            onTriggered: {
                root.active = root.active.filter(e => e !== target);
                destroy();
            }
            Component.onCompleted: start();
        }
    }
}

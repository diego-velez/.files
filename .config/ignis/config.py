from ignis.widgets import Widget
from ignis.services.notifications import Notification, NotificationService
from ignis.app import IgnisApp

app = IgnisApp.get_default()
app.apply_css("./style.scss")

notification_service = NotificationService.get_default()


class NotificationLayout(Widget.Box):
    def __init__(self, notification: Notification):
        body = Widget.Box(
            vertical=True,
            hexpand=True,
            child=[
                Widget.Label(
                    label=notification.summary,
                    css_classes=["notification-title"],
                ),
                Widget.Label(
                    label=notification.body,
                    halign="start",
                    css_classes=["notification-body"],
                ),
            ],
        )
        super().__init__(
            spacing=20,
            child=[
                Widget.Icon(
                    image=notification.icon,
                    pixel_size=64,
                    css_classes=["notification-icon"],
                ),
                body,
            ],
            css_classes=["notification-container"],
        )


class PopupNotification(Widget.Revealer):
    def __init__(self, notification: Notification):
        super().__init__(
            child=NotificationLayout(notification),
            reveal_child=True,
        )


class NotificationList(Widget.Box):
    def __init__(self):
        super().__init__(vertical=True, spacing=10, css_classes=["notification-list"])
        for notification in notification_service.notifications:
            self.add_notification(notification)
        notification_service.connect(
            "notified",
            lambda service, notification: self.add_notification(notification),
        )

    def add_notification(self, notification: Notification):
        self.prepend(PopupNotification(notification))


class Window(Widget.Window):
    def __init__(self):
        scroller = Widget.Scroll(child=NotificationList(), css_classes=["scroller"])
        super().__init__(
            namespace="DVT_Window",
            anchor=["top", "right"],
            margin_top=5,
            margin_right=1543,
            child=scroller,
            css_classes=["window"],
        )


Window()

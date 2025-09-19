from ignis.widgets import Widget
from ignis.services.notifications import Notification, NotificationService
from ignis.app import IgnisApp
from ignis.utils import Utils

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
                    use_markup=True,
                    ellipsize="end",
                    wrap=False,
                ),
                Widget.Label(
                    label=notification.body,
                    halign="start",
                    css_classes=["notification-body"],
                    use_markup=True,
                    wrap_mode="word_char",
                    wrap=True,
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
        notification.connect("closed", lambda _: self.destroy())

    def destroy(self):
        self.reveal_child = False
        Utils.Timeout(self.transition_duration, self.unparent)


class NotificationList(Widget.Box):
    def __init__(self):
        super().__init__(vertical=True, spacing=10, css_classes=["notification-list"])
        for notification in notification_service.notifications:
            self.add_notification(notification)

        self.append(
            Widget.Label(
                label="No notifications",
                valign="center",
                vexpand=True,
                visible=notification_service.bind(
                    "notifications", lambda value: len(value) == 0
                ),
                css_classes=["notification-empty-info"],
            )
        )

        notification_service.connect(
            "notified",
            lambda _, notification: self.add_notification(notification),
        )

    def add_notification(self, notification: Notification):
        self.prepend(PopupNotification(notification))


# TODO: Place this outside of scroller
class NotificationHeader(Widget.Box):
    def __init__(self):
        notification_count = Widget.Label(
            halign="start",
            hexpand=True,
            label=notification_service.bind(
                "notifications", lambda notifications: str(len(notifications))
            ),
            css_classes=["notification-count"],
        )
        clear_all_button = Widget.Button(
            halign="end",
            child=Widget.Label(label="Clear all"),
            on_click=lambda _: notification_service.clear_all(),
            css_classes=["notification-clear-all"],
        )
        super().__init__(
            hexpand=True,
            child=[notification_count, clear_all_button],
        )


class NotificationCenter(Widget.Box):
    def __init__(self):
        super().__init__(
            vertical=True, child=[NotificationHeader(), NotificationList()]
        )


class Window(Widget.Window):
    def __init__(self):
        scroller = Widget.Scroll(
            child=NotificationCenter(),
            css_classes=["scroller"],
            hscrollbar_policy="never",
        )
        super().__init__(
            namespace="DVT_Window",
            anchor=["top", "right"],
            margin_top=5,
            margin_right=1543,
            child=scroller,
            css_classes=["window"],
        )


Window()

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

Scope {
    id: brightness

    property bool shouldShowOsd: false
    property string command
    property real currentBrightness: 0.0

    IpcHandler {
        target: "brightness"

        function change_display(command: string) {
            brightness.command = command;
            changeDisplayBrightnessProc.running = true;
            show();
        }

        function change_kbd(command: string) {
            brightness.command = command;
            changeKbdBrightnessProc.running = true;
            show();
        }

        function show() {
            brightness.shouldShowOsd = true;
            hideTimer.restart();
        }
    }

    Process {
        id: changeDisplayBrightnessProc

        command: ["brightnessctl", "set", brightness.command]
        running: false
        onRunningChanged: if (!running)
            currentDisplayBrightnessProc.running = true
    }

    Process {
        id: changeKbdBrightnessProc

        command: ["brightnessctl", "set", "--device=asus::kbd_backlight", brightness.command]
        running: false
        onRunningChanged: if (!running)
            currentKbdBrightnessProc.running = true
    }

    Process {
        id: currentDisplayBrightnessProc

        command: ["brightnessctl", "get", "--percentage"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: brightness.currentBrightness = parseFloat(this.text.trim()) / 100
        }
    }

    Process {
        id: currentKbdBrightnessProc

        command: ["brightnessctl", "get", "--device=asus::kbd_backlight", "--percentage"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: brightness.currentBrightness = parseFloat(this.text.trim()) / 100
        }
    }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: brightness.shouldShowOsd = false
    }

    // The OSD window will be created and destroyed based on shouldShowOsd.
    // PanelWindow.visible could be set instead of using a loader, but using
    // a loader will reduce the memory overhead when the window isn't open.
    LazyLoader {
        active: brightness.shouldShowOsd

        PanelWindow {
            // Since the panel's screen is unset, it will be picked by the compositor
            // when the window is created. Most compositors pick the current active monitor.

            anchors.bottom: true
            margins.bottom: screen.height / 5
            exclusiveZone: 0

            implicitWidth: 400
            implicitHeight: 50
            color: "transparent"

            // An empty click mask prevents the window from blocking mouse events.
            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: "#E0282A36"

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 15
                    }

                    IconImage {
                        visible: brightness.currentBrightness < 0.35
                        implicitSize: 30
                        source: Quickshell.iconPath("display-brightness-low-symbolic")
                    }

                    IconImage {
                        visible: brightness.currentBrightness >= 0.35 && brightness.currentBrightness < 0.7
                        implicitSize: 30
                        source: Quickshell.iconPath("display-brightness-medium-symbolic")
                    }

                    IconImage {
                        visible: brightness.currentBrightness >= 0.7
                        implicitSize: 30
                        source: Quickshell.iconPath("display-brightness-high-symbolic")
                    }

                    Rectangle {
                        id: bar

                        // Stretches to fill all left-over space
                        Layout.fillWidth: true

                        implicitHeight: 10
                        radius: 20
                        color: "#50F8F8F2"

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            color: "#F8F8F2"
                            implicitWidth: parent.width * brightness.currentBrightness
                            radius: parent.radius
                        }
                    }
                }
            }
        }
    }
}

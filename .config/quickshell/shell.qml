//@ pragma IconTheme dracula-icons

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

Scope {
    id: root

    // Bind the pipewire node so its volume will be tracked
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            root.shouldShowOsd = true;
            hideTimer.restart();
        }

        function onMutedChanged() {
            root.shouldShowOsd = true;
            hideTimer.restart();
        }
    }

    property bool shouldShowOsd: false

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    // The OSD window will be created and destroyed based on shouldShowOsd.
    // PanelWindow.visible could be set instead of using a loader, but using
    // a loader will reduce the memory overhead when the window isn't open.
    LazyLoader {
        active: root.shouldShowOsd

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
                color: "#80000000"

                RowLayout {
                    id: hi

                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 15
                    }

                    IconImage {
                        visible: Pipewire.defaultAudioSink?.audio.muted
                        implicitSize: 30
                        source: Quickshell.iconPath("audio-volume-muted-symbolic")
                    }

                    IconImage {
                        visible: Pipewire.defaultAudioSink?.audio.volume < 0.35 && !Pipewire.defaultAudioSink?.audio.muted
                        implicitSize: 30
                        source: Quickshell.iconPath("audio-volume-low-symbolic")
                    }

                    IconImage {
                        visible: Pipewire.defaultAudioSink?.audio.volume >= 0.35 && Pipewire.defaultAudioSink?.audio.volume < 0.7 && !Pipewire.defaultAudioSink?.audio.muted
                        implicitSize: 30
                        source: Quickshell.iconPath("audio-volume-medium-symbolic")
                    }

                    IconImage {
                        visible: Pipewire.defaultAudioSink?.audio.volume >= 0.7 && Pipewire.defaultAudioSink?.audio.volume < 1 && !Pipewire.defaultAudioSink?.audio.muted
                        implicitSize: 30
                        source: Quickshell.iconPath("audio-volume-high-symbolic")
                    }

                    IconImage {
                        visible: Pipewire.defaultAudioSink?.audio.volume > 1 && !Pipewire.defaultAudioSink?.audio.muted
                        implicitSize: 30
                        source: Quickshell.iconPath("audio-volume-overamplified-symbolic")
                    }

                    Rectangle {
                        // Stretches to fill all left-over space
                        Layout.fillWidth: true

                        implicitHeight: 10
                        radius: 20
                        color: "#50ffffff"

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio.volume / 1.5 ?? 0)
                            radius: parent.radius
                        }
                    }
                }
            }
        }
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0
import "Components"
import Sailfish.Pickers 1.0

Page {
    id: page

    property string wallpaperUrl
    property string wallpaperTemplate: "img/ambience-template.png"
    property string highlightColor: Theme.highlightColor
    property string _originalHighlightColor: Theme.secondaryHighlightColor

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: mainWindow.orient

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Create shareable RPM")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            //spacing: Theme.paddingLarge
            MouseArea {
                width: parent.width
                height: 2 * (Screen.sizeCategory >= Screen.Large
                             ? Theme.itemSizeExtraLarge + (2 * Theme.paddingLarge)
                             : Screen.height / 5)

                Image {
                    id: image
                    anchors.fill: parent
                    source: {
                        if (wallpaperUrl != "") return wallpaperUrl
                        else return wallpaperTemplate
                    }
                    fillMode: Image.PreserveAspectCrop
                }

                OpacityRampEffect {
                    offset: 0.5
                    slope: 2.0
                    direction: OpacityRamp.BottomToTop
                    sourceItem: image
                }
                onClicked: pageStack.push(openFileDialog)
            }

            MouseArea {
                id: highlightColorSelect

                width: parent.width
                height: Theme.itemSizeLarge

                clip: true
                enabled: true
                onClicked: {
                    // Open Color Page with selected color as highlight
                    console.log("Open Highlight Color Chooser")
                    pageStack.push(Qt.resolvedUrl("ColorChooser.qml"))
                }

                Wallpaper {
                    id: wallpaper
                    anchors.fill: highlightColorSelect
                    verticalOffset: (Screen.height + image.height) / 2
                    source: {
                        if (wallpaperUrl != "") return wallpaperUrl
                        else return wallpaperTemplate
                    }

                    windowRotation: page.rotation
                }

                ShaderEffect {
                    id: dot

                    x: Theme.horizontalPageMargin
                    width: dotImage.width
                    height: dotImage.height
                    anchors.verticalCenter: highlightColorSelect.verticalCenter

                    property color color: highlightColorSelect.pressed
                                          ? page._originalHighlightColor
                                          : highlightColor
                    property Image source: Image {
                        id: dotImage
                        source: "image://theme/icon-m-dot"
                    }

                    fragmentShader: "
                                    varying highp vec2 qt_TexCoord0;
                                    uniform sampler2D source;
                                    uniform lowp vec4 color;
                                    uniform lowp float qt_Opacity;

                                    void main() {
                                        lowp vec4 tex = texture2D(source, qt_TexCoord0);
                                        gl_FragColor = color * tex.a * qt_Opacity;
                                    }"
                }

                Label {
                    id: colorLabel
                    anchors {
                        left: dot.right
                        leftMargin: Theme.paddingMedium
                        verticalCenter: highlightColorSelect.verticalCenter
                    }

                    //: Text to indicate color changes
                    //% "Ambience color"
                    text: qsTr("Highlight Color")
                    color: Theme.rgba(
                               highlightColorSelect.pressed
                               ? page._originalHighlightColor
                               : highlightColor,
                                 0.7)

                    states: State {
                        when: highlightColorSelect.enabled
                        AnchorChanges {
                            target: colorLabel
                            anchors {
                                baseline: highlightColorSelect.verticalCenter
                                verticalCenter: undefined
                            }
                        }
                        PropertyChanges {
                            target: changeLabel
                            opacity: 1
                        }
                    }

                    transitions: [
                        Transition {
                            AnchorAnimation { duration: 100 }
                            FadeAnimation { target: changeLabel; duration: 100 }
                        }
                    ]
                }

                Label {
                    id: changeLabel
                    anchors {
                        left: dot.right
                        leftMargin: Theme.paddingMedium
                        top: colorLabel.bottom
                    }
                    //: Text to indicate color changes
                    //% "Tap to reset"
                    text: qsTr("Choose highlight color for Ambience")
                    color: Theme.rgba(
                               highlightColorSelect.pressed
                               ? page._originalHighlightColor
                               : Theme.primaryColor,
                                 0.7)
                    font.pixelSize: Theme.fontSizeSmall
                    opacity: 0
                }

            }
        }
    }

    Component {
         id: openFileDialog
         FilePickerPage {
             title: "Select file"
             nameFilters: mainWindow.imageFilter
             onSelectedContentPropertiesChanged: {
                 wallpaperUrl = selectedContentProperties.filePath;
             }
         }
     }
}


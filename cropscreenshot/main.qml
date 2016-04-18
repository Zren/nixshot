import QtQuick 2.5
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

Window {
    visible: true
    flags: Qt.FramelessWindowHint | Qt.X11BypassWindowManagerHint | Qt.WindowStaysOnTopHint
    width: image.sourceSize.width
    height: image.sourceSize.height
    property rect crop
    property string inFilename: ""
    property string imageUrl: 'file://' + inFilename

    signal regionSelected(rect region)

    Component.onCompleted: {
        requestActivate()
    }

    Item {
        focus: true

        Keys.onEscapePressed: {
            console.log('onEscapePressed')
            Qt.quit(1)
        }
    }

    MouseArea {
        anchors.fill: parent

        onPressed: {
            crop.x = mouse.x
            crop.y = mouse.y
        }
        onPositionChanged: {
            crop.width = mouse.x - crop.x
            crop.height = mouse.y - crop.y
        }

        onReleased: {
            regionSelected(crop)
            Qt.quit();
        }


    }

    Image {
        id: image
        source: imageUrl

        Rectangle {
            id: dimOverlay
            anchors.fill: parent
            color: "#000"
            opacity: 0.5
            visible: true
        }
    }

    Rectangle {
        id: cropRect
        x: crop.x
        y: crop.y
        width: crop.width
        height: crop.height

        clip: true
        Image {
            id: croppedImage
            source: imageUrl
            x: -crop.x
            y: -crop.y
        }
    }

    Rectangle {
        id: cropOutline
        anchors.fill: cropRect
        color: "transparent"
        border.color: "black"
        border.width: 1
    }

}


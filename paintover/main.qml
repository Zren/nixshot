import QtQuick 2.5
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

Window {
    id: main
    visible: true
    flags: Qt.FramelessWindowHint | Qt.X11BypassWindowManagerHint | Qt.WindowStaysOnTopHint
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    property rect crop
    property string inFilename: ""
    property int cursorX: 0
    property int cursorY: 0
    property string imageUrl: 'file://' + inFilename
    property bool isCropping: false
    property bool exitOnRelease: true

    color: "transparent"

    Component.onCompleted: {
        requestActivate()
    }

    Item {
        focus: true

        Keys.onPressed: {
            if (event.key == Qt.Key_Escape) {
                Qt.quit();
                event.accepted = true
            } else if (event.matches(StandardKey.Undo)) {
                canvas.undo()
                event.accepted = true
            } else if (event.matches(StandardKey.Redo)) {
                canvas.redo()
                event.accepted = true
            } else if (event.key == Qt.Key_C) {
                colorSelector.toggle()
            }
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        property variant history: []
        property variant forwardHistory: []
        property variant currentOperation: null
        property string currentTool: 'pen'
        property color currentStrokeColor: '#f00'
        property color currentFillColor: 'transparent'
        property real currentStrokeWidth: 8

        function undo() {
            if (history.length > 0) {
                var lastOp = history.pop()
                forwardHistory.push(lastOp)
            }
            requestPaint()
        }

        function redo() {
            if (forwardHistory.length > 0) {
                var lastOp = forwardHistory.pop()
                history.push(lastOp)
            }
            requestPaint()
        }


        function startOperation(mouseX, mouseY) {
            // console.log('startOperation', mouseX, mouseY, JSON.stringify(currentOperation))
            var op = {}
            if (currentTool == 'pen') {
                op.type = 'path'
                op.strokeStyle = '' + currentStrokeColor
                op.lineWidth = currentStrokeWidth
                op.lineJoin = 'round'
                op.path = [
                    {
                        x: mouseX,
                        y: mouseY,
                    }
                ]
            }
            currentOperation = op
            forwardHistory = []
            // mouseArea.cursorShape = Qt.BlankCursor
        }

        function updateOperation(mouseX, mouseY) {
            // console.log('updateOperation', mouseX, mouseY, JSON.stringify(currentOperation))
            if (currentOperation.type == 'path') {
                currentOperation.path.push({
                    x: mouseX,
                    y: mouseY,
                })
            }
        }

        function finishOperation(mouseX, mouseY) {
            // console.log('finishOperation', mouseX, mouseY, JSON.stringify(currentOperation))
            history.push(currentOperation)
            currentOperation = null
            // mouseArea.cursorShape = Qt.ArrowCursor
        }

        function paintPath(op) {
            context.beginPath()

            for (var i = 0; i < op.path.length; i++) {
                var p = op.path[i]
                if (i == 0) {
                    context.moveTo(p.x, p.y)
                } else {
                    context.lineTo(p.x, p.y)
                }
            }
            
            applyProperty(op, 'strokeStyle')
            applyProperty(op, 'lineWidth')
            applyProperty(op, 'lineJoin')
            context.stroke()
        }

        function applyProperty(op, key) {
            if (typeof op[key] !== 'undefined') {
                context[key] = op[key]
            }
        }

        function paintOperation(op) {
            if (op.type == 'path') {
                paintPath(op)
            }
        }

        function paintHistory() {
            for (var i = 0; i < history.length; i++) {
                var op = history[i]
                paintOperation(op)
            }
        }

        function paintCurrentOperation() {
            if (currentOperation) {
                paintOperation(currentOperation)
            }
        }

        

        QtObject {
            id: colorSelector
            property bool visible: false
            property point origin: Qt.point(0,0)
            property int hueSteps: 20
            property int lightnessSteps: 5
            property int cellThickness: 20
            property int baseRadius: 20
            property variant hoveredStep: visible ? getStepAt(mouseArea.mouseX, mouseArea.mouseY) : null

            function toggle() {
                if (visible) {
                    visible = false
                    origin = Qt.point(0, 0)
                } else {
                    initSteps()
                    visible = true
                    origin = Qt.point(mouseArea.mouseX, mouseArea.mouseY)
                }
            }

            property variant steps: []

            function initSteps() {
                var arr = []
                var TAU = Math.PI*2
                for (var l = 0; l < lightnessSteps; l++) {
                    for (var h = 0; h < hueSteps; h++) {
                        var hr = h / hueSteps
                        var lr = l / lightnessSteps
                        var c = Qt.hsla(hr, 0.65, lr, 1)
                        
                        // Angle ratio 0..1 represents 0..TAU
                        var ar1 = hr
                        var ar2 = (h+1) / hueSteps

                        // Angles
                        var a1 = ar1 * TAU
                        var a2 = ar2 * TAU

                        // Radius
                        var r1 = baseRadius + l * cellThickness
                        var r2 = baseRadius + (l+1) * cellThickness

                        // console.log(h, l, c, hr, 0.65, lr, 1)
                        var step = {
                            l: l,
                            h: h,
                            hr: hr,
                            lr: lr,
                            c: c,
                            ar1: ar1,
                            ar2: ar2,
                            a1: a1,
                            a2: a2,
                            r1: r1,
                            r2: r2,
                        }
                        arr.push(step)
                    }
                }
                steps = arr
            }

            function paint(context) {
                for (var i = 0; i < steps.length; i++) {
                    var step = steps[i]
                    context.fillStyle = step.c

                    context.beginPath()
                    context.arc(origin.x, origin.y,
                        step.r1,
                        step.a1, step.a2,
                        false)
                    context.arc(origin.x, origin.y,
                        step.r2,
                        step.a2, step.a1,
                        true)
                    context.closePath()

                    context.fill()

                    if (step == hoveredStep) {
                        context.lineWidth = 3
                        context.strokeStyle = Qt.hsla(step.hr, 0.65, 1-step.lr, 1)
                        context.stroke()
                    }
                }
            }

            function getAngleFromOrigin(deltaX, deltaY) {
                // context.arc() is annoying.
                var a = Math.atan2(deltaX, deltaY)
                a = -a // It paints clockwise from 0 (so we need to inverse the angle)
                a += Math.PI/2 // atan2 returns from -PI ... +PI, and is off by 90 degrees
                if (a < 0) {
                    a += Math.PI*2
                }
                return a
            }

            function getStepAt(x, y) {
                var delta = Qt.point(x - origin.x, y - origin.y)
                var a = getAngleFromOrigin(delta.x, delta.y)
                var deltaLength = Math.sqrt(delta.x*delta.x + delta.y*delta.y)
                // console.log('getStepAt', delta.x, delta.y, a, deltaLength)
                
                for (var i = 0; i < steps.length; i++) {
                    var step = steps[i]
                    if (step.a1 <= a && a <= step.a2) {
                        if (step.r1 <= deltaLength && deltaLength <= step.r2) {
                            // console.log('\t',
                            //     a, '(', step.a1, ',', step.a2, ')',
                            //     deltaLength, '(', step.r1, ',', step.r2, ')')
                            return step
                        }
                    }
                }
                return null
            }

            function getColorAt(x, y) {
                var step = getStepAt(x, y)
                if (step) {
                    return step.c
                } else {
                    return "transparent"
                }
            }

            function select() {
                if (hoveredStep) {
                    console.log('colorSelector.select', canvas.currentStrokeColor, '=>', hoveredStep.c)
                    canvas.currentStrokeColor = hoveredStep.c
                }
                toggle()
            }
        }


        function paintMouse() {
            if (colorSelector.visible) {
                colorSelector.paint(context)
            } else if (currentTool == 'pen') {

                context.beginPath()
                context.arc(mouseArea.mouseX, mouseArea.mouseY,
                    currentStrokeWidth,
                    0, Math.PI*2,
                    false)
                context.lineWidth = 1
                context.strokeStyle = currentStrokeColor
                context.stroke()
            }
        }

        function paintAll() {
            paintHistory()
            paintCurrentOperation()
            paintMouse()
        }

        onPaint: {
            if (!context) {
                getContext('2d')
            }

            context.clearRect(0, 0, width, height)
            paintAll()
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.CrossCursor

            onPressed: {
                canvas.startOperation(mouseX, mouseY)
                canvas.requestPaint()
            }
            onPositionChanged: {
                if (canvas.currentOperation) {
                    canvas.updateOperation(mouseX, mouseY)
                }
                canvas.requestPaint()
            }
            onReleased: {
                if (canvas.currentOperation) {
                    canvas.finishOperation(mouseX, mouseY)
                }
                if (colorSelector.visible) {
                    colorSelector.select()
                }
                canvas.requestPaint()
            }
        }
    }

    property bool showHelp: true
    Item {
        id: helpOverlay
        visible: showHelp
        x: 10
        y: 10
        width: helpText.implicitWidth + padding * 2
        height: helpText.implicitHeight + padding * 2
        property int padding: 10

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.75
        }
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "black"
            border.width: 1
        }

        Text {
            id: helpText
            color: "white"
            anchors.fill: parent
            anchors.margins: parent.padding
            textFormat: Text.RichText
            text: {
                var lines = [
                    "[F1] Hide Tips",
                    "",
                    "[Hold left click] Start region selection",
                    "[Esc] Cancel capture",
                    "",
                    "[Space] Fullscreen capture",
                    "",
                    "[Mouse wheel] Change magnifier pixel count",
                    "[Ctrl + Mouse wheel] Change magnifier pixel size",
                    "[I] Hide position and size info",
                    "[M] Hide magnifier",
                    // "[C] Show screen wide crosshair"
                    

                ];

                return lines.join('<br>');
            }
        }
    }
    

}


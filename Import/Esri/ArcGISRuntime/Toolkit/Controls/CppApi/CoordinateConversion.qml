import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.2
import Esri.ArcGISRuntime.Toolkit.CppApi 100.2

/*!
    \qmltype CoordinateConversion
    \inqmlmodule Esri.ArcGISRuntime.Toolkit.Controls
    \ingroup ToolCoordinateConversion
    \since Esri.ArcGISRutime 100.2
    \brief The user interface for the coordinate conversion tool.
    \sa {Coordinate Conversion Tool}
*/

Item {
    id: coordinateConversionWindow

    /*!
      \qmlproperty real scaleFactor
      \brief The scale factor used for sizing UI elements.

      Pixel density and screen resolution varies greatly between different
      devices and operating systems. This property allows your app to specify
      the width or height of UI elements so that the sizes appear similar
      (relative to screen size) across devices. Here is an example of how to
      use this property.

      \code
         CoordinateConversion {
            buttonWidth: 90 * scaleFactor
            spacingValue: 8 * scaleFactor
            ...
         }
      \endcode
     */
    property real scaleFactor: (Screen.logicalPixelDensity * 25.4) / (Qt.platform.os === "windows" ? 96 : 72)

    /*!
      \qmlproperty int textColor
      \brief The color of coordinate notation text and labels on this tool.

      The default value is \c "black".
     */
    property color textColor: "black"

    /*!
      \qmlproperty int highlightColor
      \brief The color of used to highlight UI elements in this tool.

      The default value is \c "blue".
     */
    property color highlightColor: "blue"

    /*!
      \qmlproperty int backgroundColor
      \brief The color of used to for background UI elements in this tool.

      The default value is \c "blue".
     */
    property color backgroundColor: "white"

    /*!
      \qmlproperty int fontSize
      \brief The font size of coordinate notation text on this tool.

      The default value is \c 12.
     */
    property int fontSize: 12

    /*!
      \qmlproperty int fontFamily
      \brief The font family for text on this tool.
     */
    property string fontFamily: ""

    /*!
      \qmlproperty bool expandUpwards
      \brief Whether the tool should expand upwards as new UI elements are added.

      The default value is \c true.
     */
    property bool expandUpwards: true

    CoordinateConversionController {
        id: coordinateConvController
        objectName: "coordinateConversionController"
        active: coordinateConversionWindow.visible

        onActiveChanged: {
            if (!active && coordinateConversionWindow.visible)
                coordinateConversionWindow.visible = false;
            else if (active && !coordinateConversionWindow.visible)
                coordinateConversionWindow.visible = true;
        }
    }

    Button {
        id: inputModeButton
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        width: inputModesMenu.width
        text: coordinateConvController.inputFormat

        background: Rectangle {
            color: inputModeButton.down ? highlightColor : backgroundColor
        }

        contentItem: Text {
            text: inputModeButton.text
            font{
                bold: true
                family: fontFamily
                pixelSize: coordinateConversionWindow.fontSize * scaleFactor
            }
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        onClicked: {
            inputModesMenu.visible = true;
        }

        Menu {
            id: inputModesMenu
            x: inputModeButton.x
            y: expandUpwards ? -implicitHeight : inputModeButton.height
            visible: false

            Repeater {
                model: coordinateConvController.coordinateFormats

                delegate: Button{
                    id: inputModeOptionButton
                    text: modelData.toUpperCase()
                    anchors{
                        left: parent.left
                    }

                    background: Rectangle {
                        color: text === inputModeButton.text ? highlightColor : backgroundColor
                    }

                    contentItem: Text {
                        text: inputModeOptionButton.text.toUpperCase()
                        font{
                            family: fontFamily
                            pixelSize: coordinateConversionWindow.fontSize * scaleFactor
                        }
                        color: textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    onClicked: {
                        coordinateConvController.inputFormat = modelData;
                        inputModesMenu.close();
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: pointToConvertEntry
        color: backgroundColor
    }

    TextField {
        id: pointToConvertEntry

        anchors {
            left: inputModeButton.right
            verticalCenter: inputModeButton.verticalCenter
            right: menuButton.left
        }
        height: inputModeButton.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft

        text: coordinateConvController.pointToConvert
        placeholderText: "No position"
        font{
            family: fontFamily
            pixelSize: coordinateConversionWindow.fontSize * scaleFactor
        }
        color: textColor
    }

    Button {
        id: menuButton

        anchors {
            verticalCenter: inputModeButton.verticalCenter
            right: parent.right
        }
        height: inputModeButton.height
        width: height

        checkable: true
        checked: false

        background: Rectangle {
            anchors.fill: menuButton
            color: backgroundColor
        }

        Image {
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: menuButton
            sourceSize.height: menuButton.width
            height: sourceSize.height
            source: menuButton.checked ? "images/menuCollapse.png" : "images/menuExpand.png"
        }
    }

    Button {
        id: addConversionButton
        anchors {
            left: parent.left
            bottom: results.top
        }
        visible: menuButton.checked
        text: "Add conversion"

        background: Rectangle {
            color: addConversionButton.down ? highlightColor : backgroundColor
        }

        contentItem: Text {
            text: addConversionButton.text
            font{
                family: fontFamily
                pixelSize: coordinateConversionWindow.fontSize * scaleFactor
            }
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        onClicked: {
            addConversionMenu.visible = true;
        }

        Menu {
            id: addConversionMenu
            x: addConversionButton.x
            y: expandUpwards ? -implicitHeight : addConversionButton.height
            visible: false

            Repeater {
                model: coordinateConvController.coordinateFormats

                delegate: Button{
                    id: addConversionOptionButton
                    text: modelData
                    enabled: text !== inputModeButton.text
                    opacity: enabled ? 1.0 : 0.5
                    anchors{
                        left: parent.left
                    }

                    background: Rectangle {
                        color: backgroundColor
                    }

                    contentItem: Text {
                        text: addConversionOptionButton.text.toUpperCase()
                        font{
                            family: fontFamily
                            pixelSize: coordinateConversionWindow.fontSize * scaleFactor
                        }
                        color: textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    onClicked: {
                        coordinateConvController.addCoordinateFormat(modelData);
                        addConversionMenu.close();
                    }
                }
            }
        }
    }

    Button {
        id: captureModeButton

        anchors {
            verticalCenter: addConversionButton.verticalCenter
            left: addConversionButton.right
        }
        height: addConversionButton.height
        width: height

        visible: menuButton.checked
        checkable: true
        checked: coordinateConvController.captureMode

        background: Rectangle {
            anchors.fill: captureModeButton
            color: backgroundColor
            border {
                color: captureModeButton.checked ? highlightColor : "transparent"
                width: 1 * scaleFactor
            }

        }

        Image {
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            sourceSize.height: parent.width
            height: sourceSize.height
            opacity: captureModeButton.checked ? 1.0 : 0.5
            source: "images/directionsto_dark.png"
        }

        onCheckedChanged: {
            if (coordinateConvController.captureMode !== checked)
                coordinateConvController.captureMode = checked;
        }
    }

    ListView {
        id: results
        anchors {
            bottom: inputModeButton.top
            left: inputModeButton.left
            right: parent.right
        }

        visible: menuButton.checked
        height: count * inputModeButton.height
        model: coordinateConvController.results

        delegate:
            Rectangle {
            height: inputModeButton.height
            width: results.width
            color: backgroundColor

            Text {
                id: formatName
                text: name
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: inputModeButton.width
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font{
                    family: fontFamily
                    pixelSize: coordinateConversionWindow.fontSize * scaleFactor
                }
                color: textColor
            }

            Text {
                text: notation
                anchors {
                    left: formatName.right
                    verticalCenter: parent.verticalCenter
                    right: removeFormat.left
                }
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                font{
                    family: fontFamily
                    pixelSize: coordinateConversionWindow.fontSize * scaleFactor
                }
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                color: textColor
            }

            Button {
                id: removeFormat
                width: height
                height: inputModeButton.height

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                Image {
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: removeFormat
                    height: removeFormat.height
                    width: height
                    source: "images/trash.png"
                }

                onClicked: {
                    coordinateConvController.removeCoordinateFormat(name);
                }
            }
        }
    }
}

//Rectangle {
//    id: coordinateConversionWindow

//    /*!
//      \qmlproperty real scaleFactor
//      \brief The scale factor used for sizing UI elements.

//      Pixel density and screen resolution varies greatly between different
//      devices and operating systems. This property allows your app to specify
//      the width or height of UI elements so that the sizes appear similar
//      (relative to screen size) across devices. Here is an example of how to
//      use this property.

//      \code
//         CoordinateConversion {
//            buttonWidth: 90 * scaleFactor
//            spacingValue: 8 * scaleFactor
//            ...
//         }
//      \endcode
//     */
//    property real scaleFactor: (Screen.logicalPixelDensity * 25.4) / (Qt.platform.os === "windows" ? 96 : 72)

//    /*!
//      \qmlproperty int buttonWidth
//      \brief The width of various buttons on this tool.

//      The default value is \c {100 * scaleFactor}.
//     */
//    property int buttonWidth: 100 * scaleFactor

//    /*!
//      \qmlproperty int spacingValue
//      \brief The spacing between rows and columns on this tool.

//      The default value is \c {5 * scaleFactor}.
//     */
//    property int spacingValue: 5 * scaleFactor

//    /*!
//      \qmlproperty int imageWidth
//      \brief The width of the images used for buttons on this tool.

//      The default value is \c {36 * scaleFactor}.
//     */
//    property int imageWidth: 36 * scaleFactor

//    /*!
//      \qmlproperty int fontSize
//      \brief The font size of coordinate notation text on this tool.

//      The default value is \c {12 * scaleFactor}.
//     */
//    property int fontSize: 12 * scaleFactor

//    /*!
//      \qmlproperty int textColor
//      \brief The color of coordinate notation text and labels on this tool.

//      The default value is \c "black".
//     */
//    property color textColor: "black"

//    CoordinateConversionController {
//        id: coordinateConvController
//        objectName: "coordinateConversionController"
//        active: coordinateConversionWindow.visible

//        onActiveChanged: {
//            if (!active && coordinateConversionWindow.visible)
//                coordinateConversionWindow.visible = false;
//            else if (active && !coordinateConversionWindow.visible)
//                coordinateConversionWindow.visible = true;
//        }
//    }

//    ScrollView {
//        id: scrollView
//        anchors {
//            top: parent.top
//            bottom: bottomRect.top
//            horizontalCenter: parent.horizontalCenter
//        }

//        anchors.margins: 10 * scaleFactor

//        Column {
//            id: column
//            anchors.left: parent.left
//            anchors.right: parent.right
//            spacing: spacingValue

//            Row {
//                spacing: spacingValue

//                ComboBox {
//                    id: notationTypeCombo
//                    width: buttonWidth
//                    anchors.verticalCenter: parent.verticalCenter
//                    model: CoordinateConversionOptions.coordinateTypeNames
//                    onCurrentTextChanged: {
//                        coordinateConvController.inputMode = CoordinateConversionOptions.stringToCoordinateType(currentText);
//                    }
//                }

//                TextField {
//                    id: inputNotation
//                    width: coordinateConversionWindow.width * 0.7
//                    color: textColor
//                    font.pixelSize: fontSize
//                }

//                RoundButton {
//                    id: convertButton
//                    width: 32 * scaleFactor
//                    height: 32 * scaleFactor

//                    background: Rectangle {
//                        color: Material.accent
//                        radius: convertButton.radius

//                        Image {
//                            anchors.centerIn: parent
//                            sourceSize.width: 26 * scaleFactor
//                            height: width
//                            source: "images/convert.png"
//                        }
//                    }

//                    onClicked: {
//                        coordinateConvController.convertNotation(inputNotation.text);
//                    }
//                }
//            }

//            Repeater {
//                id: repeater
//                model: coordinateConvController.results

//                delegate: Row {
//                    spacing: spacingValue

//                    Label {
//                        id: repeaterLabel
//                        anchors.verticalCenter: parent.verticalCenter
//                        width: buttonWidth
//                        text: name
//                        color: textColor
//                    }

//                    TextField {
//                        id: notationBox
//                        anchors.verticalCenter: parent.verticalCenter
//                        text: notation
//                        width: coordinateConversionWindow.width * 0.7
//                        color: textColor
//                        font.pixelSize: fontSize
//                    }

//                    RoundButton {
//                        id: copyButton
//                        width: 32 * scaleFactor
//                        height: 32 * scaleFactor

//                        background: Rectangle {
//                            color: Material.primary
//                            radius: copyButton.radius

//                            Image {
//                                anchors.centerIn: parent
//                                sourceSize.width: 26 * scaleFactor
//                                height: width
//                                source: "images/editcopy.png"
//                            }
//                        }

//                        onClicked: {
//                            coordinateConvController.copyToClipboard(notationBox.text);
//                            notationTypeCombo.currentIndex = notationTypeCombo.model.indexOf(CoordinateConversionOptions.coordinateTypeToString(coordinateType));
//                        }
//                    }
//                }
//            }
//        }
//    }

//    Rectangle {
//        id: bottomRect

//        anchors {
//            bottom: parent.bottom
//            left: parent.left
//            right: coordinateConversionWindow.right
//            topMargin: 5 * scaleFactor
//        }
//        height: 40 * scaleFactor
//        color: Material.primary

//        CheckBox {
//            id: getFromMap
//            anchors {
//                right: clear.left
//                bottom: parent.bottom
//                top: parent.top
//                rightMargin: 10 * scaleFactor
//            }

//            onCheckedChanged: {
//                coordinateConvController.runConversion = checked;
//            }
//        }

//        Button {
//            id: useLocationFromMap
//            width: 32 * scaleFactor
//            height: 32 * scaleFactor
//            checkable: true
//            checked: false

//            anchors {
//                right: clear.left
//                bottom: parent.bottom
//                top: parent.top
//                rightMargin: 10 * scaleFactor
//            }

//            background: Rectangle {
//                anchors.fill: this
//                color: Material.primary
//            }

//            Image {
//                id: img
//                fillMode: Image.PreserveAspectFit
//                anchors.centerIn: parent
//                sourceSize.height: parent.width
//                height: sourceSize.height
//                opacity: useLocationFromMap.checked ? 1.0 : 0.5
//                source: "images/directionsto_dark.png"
//            }

//            onCheckedChanged: {
//                coordinateConvController.runConversion = checked;
//            }
//        }

//        Button {
//            id: clear
//            width: 32 * scaleFactor
//            height: 32 * scaleFactor

//            anchors {
//                right: parent.right
//                rightMargin: (coordinateConversionWindow.width - (coordinateConversionWindow.width * 0.7 + buttonWidth + spacingValue * 4 + clear.width)) * scaleFactor
//                verticalCenter: parent.verticalCenter
//            }

//            background: Rectangle {
//                anchors.fill: this
//                color: Material.primary
//            }

//            Image {
//                fillMode: Image.PreserveAspectFit
//                anchors.centerIn: parent
//                sourceSize.height: parent.width
//                height: sourceSize.height
//                source: "images/trash.png"
//            }


//            onClicked: {
//                coordinateConvController.clearResults();
//            }
//        }
//    }
//}

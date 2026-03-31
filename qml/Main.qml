// main.qml
import QtQuick
import "."               // import the qml folder

Window {
    id: rootWindow

    visible: true
    width: 1024
    height: 768
    title: qsTr("SweetHome3D → Qt Quick 3D")

    // Load the scene we defined above
    SceneLoader {
        anchors.fill: parent
    }
}

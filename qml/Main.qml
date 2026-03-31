// main.qml
import QtQuick
import "."               // import the qml folder

Window {
    id: rootWindow

    visible: true
    width: 1024
    height: 768
    title: qsTr("SweetHome3D → Qt Quick 3D")

    property url xmlSourceDir: "file:///home/chris/dev/projects/sh3d-viewer-qml/tests/Plan_appart_latest_from_plan/"

    // Load the scene we defined above
    SceneLoader {
        anchors.fill: parent
        // Point to the directory containing your SweetHome3D Home.xml file, with trailing slash
        xmlSourceDir: rootWindow.xmlSourceDir
    }
}

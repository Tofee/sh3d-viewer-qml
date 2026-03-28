// main.qml
import QtQuick
import "."               // import the qml folder

Window {
    visible: true
    width: 1024
    height: 768
    title: qsTr("SweetHome3D → Qt Quick 3D")

    // Load the scene we defined above
    SceneLoader {
        anchors.fill: parent
        // Point to your actual SweetHome3D XML file
//        xmlSourceDir: "file:///home/chris/dev/projects/sh3d-viewer-qml/tests/simple-home/"
//        xmlSource: "file:///home/chris/dev/projects/sh3d-viewer-qml/tests/Appart_Home.xml"
        xmlSourceDir: "file:///home/chris/dev/projects/sh3d-viewer-qml/tests/DessinAppartComePrecis_remodelage/"
    }
}

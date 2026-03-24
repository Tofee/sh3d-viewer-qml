// main.qml
import QtQuick 2.15
import QtQuick.Window 2.15
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
        xmlSource: "file:///C:/Users/you/Documents/house.xml"
    }
}

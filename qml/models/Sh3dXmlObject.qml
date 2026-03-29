// RoomModel.qml
import QtQuick

QtObject {
    id: model
    property url xmlModelFile
    property variant xmlDocument

    signal loadCompleted

    // read xml file
    function readXmlFile(): bool {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", model.xmlModelFile.toString());
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                model.xmlDocument = xhr.responseXML;
                model.loadCompleted();
            }
        };
        xhr.send();
    }
    Component.onCompleted: {
        model.readXmlFile();
    }
}

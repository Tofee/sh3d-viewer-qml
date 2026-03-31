// RoomModel.qml
import QtQuick
import QtQml.Models
import sh3d_viewer_qml

ListModel {
    id: sh3DXmlListModel
    property string query;
    property string skipNode: "furnitureGroup";
    property variant defaultInitValues;
    signal loadModelCompleted;

    function loadElementsFromDocumentWithQuery() {
        let toProcess = Sh3dHomeModel.runQuery(query, skipNode);

        // we found no match, just leave the model empty.
        for (let j=0; j<toProcess.length; ++j) {
            _addFoundChildToListModel(toProcess[j]);
        }

        sh3DXmlListModel.loadModelCompleted();
    }
    function _addFoundChildToListModel(xmlElt: variant) {
        let o = {};
        for (let defaultAttr in defaultInitValues) {
            o[defaultAttr] = defaultInitValues[defaultAttr];
        }
        for (let eltAttr in xmlElt) {
            if (eltAttr === "model")
                o["modelFile"] = xmlElt[eltAttr]; // special hack to avoid conflict with ListModel
            else
                o[eltAttr] = xmlElt[eltAttr];
        }
        sh3DXmlListModel.append(o);
    }

    Component.onCompleted: {
        // xml document already loaded, emit the signal to populate the list
        loadElementsFromDocumentWithQuery();
    }
}

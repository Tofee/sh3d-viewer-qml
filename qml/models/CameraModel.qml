// RoomModel.qml
import QtQuick
import QtQml.XmlListModel

XmlListModel {
    query: "/home/camera"

    XmlListModelRole { name: "attribute"; elementName: ""; attributeName: "attribute" }
    XmlListModelRole { name: "lens"; elementName: ""; attributeName: "lens" }
    XmlListModelRole { name: "x"; elementName: ""; attributeName: "x" }
    XmlListModelRole { name: "y"; elementName: ""; attributeName: "y" }
    XmlListModelRole { name: "z"; elementName: ""; attributeName: "z" }
    XmlListModelRole { name: "yaw"; elementName: ""; attributeName: "yaw" }
    XmlListModelRole { name: "pitch"; elementName: ""; attributeName: "pitch" }
    XmlListModelRole { name: "fieldOfView"; elementName: ""; attributeName: "fieldOfView" }
    XmlListModelRole { name: "time"; elementName: ""; attributeName: "time" }

    function get(i: int): variant {
        var o = {}
        for (var j = 0; j < roles.length; ++j)
        {
            o[roles[j].name] = data(index(i,0), Qt.UserRole + j)
        }
        return o
    }
}

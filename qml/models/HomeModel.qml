// RoomModel.qml
import QtQuick
import QtQml.XmlListModel

XmlListModel {
    query: "/home"

    XmlListModelRole { name: "name"; elementName: ""; attributeName: "name" }
    XmlListModelRole { name: "version"; elementName: ""; attributeName: "version" }
    XmlListModelRole { name: "wallHeight"; elementName: ""; attributeName: "wallHeight" }
    XmlListModelRole { name: "camera"; elementName: ""; attributeName: "camera" }
}

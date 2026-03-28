import QtQuick
import QtQml.XmlListModel

XmlListModel {
    query: "/home/pieceOfFurniture"

    XmlListModelRole { name: "id"; elementName: ""; attributeName: "id" }
    XmlListModelRole { name: "level"; elementName: ""; attributeName: "level" }
    XmlListModelRole { name: "catalogId"; elementName: ""; attributeName: "catalogId" }
    XmlListModelRole { name: "name"; elementName: ""; attributeName: "name" }
    XmlListModelRole { name: "creator"; elementName: ""; attributeName: "creator" }
    XmlListModelRole { name: "modelFile"; elementName: ""; attributeName: "model" }
    XmlListModelRole { name: "icon"; elementName: ""; attributeName: "icon" }
    XmlListModelRole { name: "x"; elementName: ""; attributeName: "x" }
    XmlListModelRole { name: "y"; elementName: ""; attributeName: "y" }
    XmlListModelRole { name: "elevation"; elementName: ""; attributeName: "elevation" }
    XmlListModelRole { name: "angle"; elementName: ""; attributeName: "angle" }
    XmlListModelRole { name: "width"; elementName: ""; attributeName: "width" }
    XmlListModelRole { name: "height"; elementName: ""; attributeName: "height" }
    XmlListModelRole { name: "depth"; elementName: ""; attributeName: "depth" }
    XmlListModelRole { name: "modelSize"; elementName: ""; attributeName: "modelSize" }
    XmlListModelRole { name: "movable"; elementName: ""; attributeName: "movable" }
    XmlListModelRole { name: "visible"; elementName: ""; attributeName: "visible" }
    XmlListModelRole { name: "dropOnTopElevation"; elementName: ""; attributeName: "dropOnTopElevation" }
}

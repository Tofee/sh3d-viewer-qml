import QtQuick
import QtQml.XmlListModel

XmlListModel {
    query: "/home/wall"

    XmlListModelRole { name: "id"; elementName: ""; attributeName: "id" }
    XmlListModelRole { name: "wallAtStart"; elementName: ""; attributeName: "wallAtStart" }
    XmlListModelRole { name: "wallAtEnd"; elementName: ""; attributeName: "wallAtEnd" }
    XmlListModelRole { name: "xStart"; elementName: ""; attributeName: "xStart" }
    XmlListModelRole { name: "yStart"; elementName: ""; attributeName: "yStart" }
    XmlListModelRole { name: "xEnd"; elementName: ""; attributeName: "xEnd" }
    XmlListModelRole { name: "yEnd"; elementName: ""; attributeName: "yEnd" }
    XmlListModelRole { name: "height"; elementName: ""; attributeName: "height" }
    XmlListModelRole { name: "thickness"; elementName: ""; attributeName: "thickness" }
    XmlListModelRole { name: "arcExtent"; elementName: ""; attributeName: "arcExtent" }
    XmlListModelRole { name: "pattern"; elementName: ""; attributeName: "pattern" }
}

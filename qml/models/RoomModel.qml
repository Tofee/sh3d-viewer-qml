import QtQuick
import QtQml.XmlListModel

XmlListModel {
    id: wallModel
    query: "/home/wall"

    XmlListModelRole { name: "id"; elementName: ""; attributeName: "id" }
    XmlListModelRole { name: "floorVisible"; elementName: ""; attributeName: "floorVisible" }
    XmlListModelRole { name: "floorColor"; elementName: ""; attributeName: "floorColor" }
    XmlListModelRole { name: "floorShininess"; elementName: ""; attributeName: "floorShininess" }
    XmlListModelRole { name: "ceilingVisible"; elementName: ""; attributeName: "ceilingVisible" }
    XmlListModelRole { name: "ceilingColor"; elementName: ""; attributeName: "ceilingColor" }
    XmlListModelRole { name: "ceilingShininess"; elementName: ""; attributeName: "ceilingShininess" }
    XmlListModelRole { name: "ceilingFlat"; elementName: ""; attributeName: "ceilingFlat" }

    property XmlListModel roomPoints: XmlListModel {
        id: roomPoints
        query: "/home/wall"
        source: wallModel.source

        XmlListModelRole { name: "x"; elementName: "point"; attributeName: "x" }
        XmlListModelRole { name: "y"; elementName: "point"; attributeName: "y" }

        function getPoints(): variant {
            var listPoints = []
            for (let j = 0; j < count; ++j)
            {
                listPoints.push({
                    x: data(index(j,0), Qt.UserRole + 0),
                    y: data(index(j,0), Qt.UserRole + 1)
                });
            }
            return listPoints;
        }
    }
}


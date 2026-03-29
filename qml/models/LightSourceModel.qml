import QtQuick
import "."

Sh3dXmlModel {
    query: "/home/light[@id='"+queryLightId+"']/lightSource"
    property string queryLightId
}

// RoomModel.qml
import QtQuick 2.15

ListModel {
    // A room is defined by a list of wall IDs that close the polygon.
    // We also expose floor/ceiling colours for quick material creation.
    // Example entry:
    // { "name": "Living Room", "wallIds": "1,2,3,4", "floorColor": "#e0e0e0", "ceilingColor": "#ffffff" }
}
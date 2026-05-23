import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import "."
import "../models"

Node {
    id: roomNode
    property RoomPointsModel roomPointsModel
    property string roomId
    property bool floorVisible
    property color floorColor
    property real floorShininess
    property real ceilingVisible
    property color ceilingColor
    property real ceilingShininess
    property real ceilingFlat
    property variant roomPoints
    property real levelElevation: 0

    // Floor
    FloorOrCeiling {
        id: floorModel
        visible: roomNode.floorVisible
        roomPoints: roomPointsModel.allPoints
        levelElevation: roomNode.levelElevation

        roomId: roomNode.roomId
    }
/*
    // Ceiling
    FloorOrCeiling {
        id: ceilingModel
        visible: ceilingVisible
        roomPoints: roomPointsModel.allPoints

        roomId: roomNode.roomId
    }*/
}

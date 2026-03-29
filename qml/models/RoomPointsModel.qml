import QtQuick
import "."

Sh3dXmlModel {
    id: roomPointsModel
    query: "/home/room[@id='"+queryRoomId+"']/point"
    property string queryRoomId
    property variant allPoints: []

    onLoadModelCompleted: {
        let newPointsList = []
        for (let i=0; i<count; ++i)
            newPointsList.push({x: get(i).x, y: get(i).y});

        allPoints = newPointsList; // assign all points in one go
    }
}

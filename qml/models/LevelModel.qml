// RoomModel.qml
import QtQuick
import "."

Sh3dXmlModel {
    query: "/level"

    function getElevationForId(levelId: string):real {
        for (let i=0; i<count; ++i) {
            let level_i = get(i);
            if (level_i.id === levelId) {
                return level_i.elevation;
            }
        }

        console.warn("WARNING: Found level "+levelId+" NOT FOUND");
        return 0; // level not found
    }
}

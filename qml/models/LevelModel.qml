// RoomModel.qml
import QtQuick
import "."

Sh3dXmlModel {
    query: "/level"

    function getElevationForId(levelId: string):real {
        if (!levelId || levelId === 'undefined') return 0;

        for (let i=0; i<count; ++i) {
            let level_i = get(i);
            if (level_i.id === levelId) {
                return level_i.elevation;
            }
        }

        console.warn("WARNING: Level "+levelId+" NOT FOUND");
        return 0; // level not found
    }
}

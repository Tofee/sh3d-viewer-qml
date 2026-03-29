import QtQuick
import "."

Sh3dXmlModel {
    id: roomModel
    query: "/home/room"
    defaultInitValues: ({ floorVisible: 'true',
                          areaVisible: 'true',
                          floorColor: '0',
                          floorShininess: '0',
                          ceilingVisible: 'false',
                          ceilingColor: '0',
                          ceilingShininess: '0',
                          ceilingFlat: 'true'})
}


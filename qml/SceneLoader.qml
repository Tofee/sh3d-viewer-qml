// SceneLoader.qml
import QtQuick 2.15
import QtQuick3D 1.15
import QtQuick.XmlListModel 2.0   // for parsing the XML
import "."                       // import the models defined above

Item {
    id: root
    width: 800
    height: 600

    // -----------------------------------------------------------------
    //  XML source – replace with the real path to your .sh3d file
    // -----------------------------------------------------------------
    property url xmlSource: "file:///path/to/your/house.xml"

    // -----------------------------------------------------------------
    // Populate the ListModels from the XML
    // -----------------------------------------------------------------
    XmlListModel {
        id: xmlModel
        source: root.xmlSource
        query: "/home/*"   // we will filter per element below
    }

    // Helper: copy a node list into a ListModel
    function fillModel(xmlQuery, targetModel, fields) {
        var nodes = xmlModel.query(xmlQuery);
        targetModel.clear();
        for (var i = 0; i < nodes.length; ++i) {
            var node = nodes[i];
            var entry = {};
            for (var f = 0; f < fields.length; ++f) {
                var field = fields[f];
                entry[field] = node.attribute(field);
            }
            targetModel.append(entry);
        }
    }

    // -----------------------------------------------------------------
    // Fill each model when the XML is loaded
    // -----------------------------------------------------------------
    Component.onCompleted: {
        // Home (just for completeness)
        fillModel("home", HomeModel, ["name", "version"]);

        // Walls
        fillModel("wall", WallModel,
                  ["x1","y1","x2","y2","height","thickness"]);

        // Rooms
        fillModel("room", RoomModel,
                  ["name","wallIds","floorColor","ceilingColor"]);

        // Furniture
        fillModel("furniture", FurnitureModel,
                  ["name","x","y","z","angle","modelFile"]);

        // Doors
        fillModel("door", DoorModel,
                  ["wallId","x","y","width","height"]);

        // Windows
        fillModel("window", WindowModel,
                  ["wallId","x","y","width","height"]);

        // Lights
        fillModel("light", LightModel,
                  ["type","x","y","z","intensity","color"]);

        // Camera (optional)
        fillModel("camera", CameraModel,
                  ["x","y","z","rx","ry","rz"]);
    }

    // -----------------------------------------------------------------
    //  Build the 3‑D scene from the populated models
    // -----------------------------------------------------------------
    View3D {
        anchors.fill: parent
        camera: Camera {
            // If a saved camera exists, use it; otherwise default.
            Component.onCompleted: {
                if (CameraModel.count > 0) {
                    var cam = CameraModel.get(0);
                    position = Qt.vector3d(cam.x, cam.y, cam.z);
                    rotation = Qt.vector3d(cam.rx, cam.ry, cam.rz);
                }
            }
        }

        // ----- Walls ----------------------------------------------------
        Repeater {
            model: WallModel
            delegate: Model {
                // Simple rectangular prism for a wall
                source: "#Cube"
                materials: DefaultMaterial { diffuseColor: "#c0c0c0" }

                // Compute centre + orientation from the two end points
                property real dx: x2 - x1
                property real dy: y2 - y1
                property real length: Math.sqrt(dx*dx + dy*dy)
                property real angle: Math.atan2(dy, dx) * 180 / Math.PI

                position: Qt.vector3d((x1 + x2)/2, (y1 + y2)/2, height/2)
                scale: Qt.vector3d(length/1000, thickness/1000, height/1000)
                eulerRotation: Qt.vector3d(0, 0, angle)
            }
        }

        // ----- Furniture ------------------------------------------------
        Repeater {
            model: FurnitureModel
            delegate: Model {
                source: modelFile   // expects a GLTF/OBJ file relative to the app
                eulerRotation: Qt.vector3d(0, angle, 0)
                position: Qt.vector3d(x, y, z)
                // optional: scale, material overrides, etc.
            }
        }

        // ----- Lights ---------------------------------------------------
        Repeater {
            model: LightModel
            delegate: Light {
                type: (type === "point") ? Light.Point : (type === "spot") ? Light.Spot : Light.Directional
                position: Qt.vector3d(x, y, z)
                intensity: intensity
                color: color
            }
        }

        // ----- Doors & Windows (cutouts) --------------------------------
        // For simplicity we just render them as thin boxes; a real app would
        // subtract them from the wall geometry using a Boolean operation.
        Repeater {
            model: DoorModel
            delegate: Model {
                source: "#DoorGeometry"
                materials: DefaultMaterial { diffuseColor: "#8b4513" }
                // Position relative to the owning wall (wallId is ignored here)
                position: Qt.vector3d(x, y, height/2)
                scale: Qt.vector3d(width/1000, thickness/1000, height/1000)
            }
        }

        Repeater {
            model: WindowModel
            delegate: Model {
                source: "#WindowGeometry"
                materials: DefaultMaterial { diffuseColor: "#87cefa"; opacity: 0.5 }
                position: Qt.vector3d(x, y, height/2)
                scale: Qt.vector3d(width/1000, thickness/1000, height/1000)
            }
        }

        Geometry { id: DoorGeometry; source: WallGeometry }
        Geometry { id: WindowGeometry; source: WallGeometry }
    }
}

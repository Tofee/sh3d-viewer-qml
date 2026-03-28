// SceneLoader.qml
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils
import QtQml.XmlListModel
import QtQml.Models
import "."
import "views"
import "models"

Item {
    id: root

    // -----------------------------------------------------------------
    //  XML source – replace with the real path to your .sh3d file
    // -----------------------------------------------------------------
    property url xmlSourceDir: "file:///path/to/your/house/dir/"
    property url homeXmlSource: root.xmlSourceDir + "Home.xml"

    HomeModel {
        id: homeModel
        source: root.homeXmlSource
    }
    WallModel {
        id: wallModel
        source: root.homeXmlSource
    }
    RoomModel {
        id: roomModel
        source: root.homeXmlSource
    }
    FurnitureModel {
        id: furnitureModel
        source: root.homeXmlSource
    }
    CameraModel {
        id: cameraModel
        source: root.homeXmlSource

        onStatusChanged: if (status === XmlListModel.Ready && cameraModel.count>0) {
                             var cam = cameraModel.get(0);
                             mainCamera.position = vec3_Y_UP(cam.x, cam.y, cam.z);
                             mainCamera.fieldOfView = cam.fieldOfView * 180 / Math.PI;
                             mainCamera.eulerRotation = vec3_Y_UP(cam.yaw * 180 / Math.PI - 90, 0, 180 - cam.pitch * 180 / Math.PI);
                         }
    }

    /* -----------------------------------------------------------------
     *  Build the 3‑D scene from the populated models
     *  *** note: SweetHome3D's view is Y-UP based (comes from Java3D).
     *            So the easiest to match the visualization is to do the
     *            same here too.
     *  *** This means the drawing plan is actually the XZ plan.
     * ----------------------------------------------------------------- */

    function vec3_Y_UP(_x, _y, _z): vector3d {
        return Qt.vector3d(_x, _z, _y);
    }

    View3D {
        id: mainView3D
        anchors.fill: parent
        environment: SceneEnvironment {
            antialiasingMode: SceneEnvironment.MSAA
            tonemapMode: SceneEnvironment.TonemapModeFilmic
            backgroundMode: SceneEnvironment.Color
            clearColor: "#6060A0"
        }
        camera: PerspectiveCamera {
            id: mainCamera
        }

        DirectionalLight {
            eulerRotation.x: -30
            eulerRotation.y: -70
        }

        WasdController {
            controlledObject: mainCamera
        }

        AxisHelper {
            id: axisHelper
        }

        // ----- Walls ----------------------------------------------------
        Repeater3D {
            model: wallModel
            delegate: WallDelegate {
                xStart: model.xStart
                xEnd: model.xEnd
                yStart: model.yStart
                yEnd: model.yEnd
                thickness: model.thickness
                height: model.height
                arcExtent: model.arcExtent
            }
        }

        // ----- rooms (floor & ceiling)------------------------------------
        Repeater3D {
            model: roomModel
            delegate: RoomDelegate {
                floorVisible: model.floorVisibl
                floorColor: model.floorColor
                floorShininess: model.floorShinin
                ceilingVisible: model.ceilingVisi
                ceilingColor: model.ceilingColo
                ceilingShininess: model.ceilingShin
                ceilingFlat: model.ceilingFlat
                roomPoints: roomModel.roomPoints
            }
        }

        // ----- Furniture ------------------------------------------------
        Repeater3D {
            model: furnitureModel
            delegate: FurnitureDelegate {
                furnitureSource: root.xmlSourceDir + (modelFile.includes(".") ? modelFile : (modelFile + ".obj"))

                modelAngle: model.angle
                modelX: model.x
                modelY: model.y
                modelHeight: model.height
                modelWidth: model.width
                modelDepth: model.depth
                modelElevation: (model.elevation || 0) // some furnitures don't have the elevation property
            }
        }

        /*
        // ----- Lights ---------------------------------------------------
        Repeater {
            model: LightModel
            delegate: Light {
                //type: (type === "point") ? Light.Point : (type === "spot") ? Light.Spot : Light.Directional
                position: Qt.vector3d(x, y, z)
                //intensity: intensity
                color: color
            }
        }

        // ----- Doors & Windows (cutouts) --------------------------------
        // For simplicity we just render them as thin boxes; a real app would
        // subtract them from the wall geometry using a Boolean operation.
        Repeater {
            model: DoorModel
            delegate: Model {
                source: "#Cube"
                materials: DefaultMaterial { diffuseColor: "#8b4513" }
                // Position relative to the owning wall (wallId is ignored here)
                position: Qt.vector3d(x, y, height/2)
                scale: Qt.vector3d(width/1000, thickness/1000, height/1000)
            }
        }

        Repeater {
            model: WindowModel
            delegate: Model {
                source: "#Cube"
                materials: DefaultMaterial { diffuseColor: "#87cefa"; opacity: 0.5 }
                position: Qt.vector3d(x, y, height/2)
                scale: Qt.vector3d(width/1000, thickness/1000, height/1000)
            }
        }
        */
    }
}

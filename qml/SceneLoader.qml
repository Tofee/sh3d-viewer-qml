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

    Sh3dXmlObject {
        id: sh3dXmlObject
        xmlModelFile: root.homeXmlSource
    }

    HomeModel {
        id: homeModel
        xmlReader: sh3dXmlObject
    }
    WallModel {
        id: wallModel
        xmlReader: sh3dXmlObject
    }
    RoomModel {
        id: roomModel
        xmlReader: sh3dXmlObject
    }
    FurnitureModel {
        id: furnitureModel
        xmlReader: sh3dXmlObject
    }
    LightModel {
        id: lightModel
        xmlReader: sh3dXmlObject
    }
    CameraModel {
        id: cameraModel
        xmlReader: sh3dXmlObject

        onLoadModelCompleted: if (cameraModel.count>0) {
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
            backgroundMode: SceneEnvironment.SkyBox
            lightProbe: Texture { source: "../resources/little_paris_eiffel_tower_2k.hdr" }
            tonemapMode: SceneEnvironment.TonemapModeFilmic
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
                roomPointsModel: RoomPointsModel {
                    xmlReader: sh3dXmlObject
                    queryRoomId: model.id

                    Component.onCompleted: loadElementsFromDocumentWithQuery()
                }

                roomId: model.id
                floorVisible: model.floorVisible || model.areaVisible
                floorColor: model.floorColor
                floorShininess: model.floorShininess
                ceilingVisible: model.ceilingVisible
                ceilingColor: model.ceilingColor
                ceilingShininess: model.ceilingShininess
                ceilingFlat: model.ceilingFlat
                roomPoints: roomModel.points
            }
        }

        // ----- Furniture ------------------------------------------------
        Repeater3D {
            model: furnitureModel
            delegate: FurnitureDelegate {
                furnitureSource: root.xmlSourceDir + (model.modelFile.includes(".") ? model.modelFile : (model.modelFile + ".obj"))

                modelAngle: model.angle
                modelX: model.x
                modelY: model.y
                modelHeight: model.height
                modelWidth: model.width
                modelDepth: model.depth
                modelElevation: (model.elevation || 0) // some furnitures don't have the elevation property
            }
        }


        // ----- Lights ---------------------------------------------------
        Repeater3D {
            model: lightModel
            delegate: LightDelegate {
                    id: lightDelegate
                    furnitureSource: root.xmlSourceDir + (model.modelFile.includes(".") ? model.modelFile : (model.modelFile + ".obj"))

                    modelAngle: 0
                    modelX: model.x
                    modelY: model.y
                    modelHeight: model.height
                    modelWidth: model.width
                    modelDepth: model.depth
                    modelElevation: (model.elevation || 0) // some furnitures don't have the elevation property

                    lightPower: model.power
                    lightSourceModel: LightSourceModel {
                        xmlReader: sh3dXmlObject
                        queryLightId: model.id

                        Component.onCompleted: loadElementsFromDocumentWithQuery()
                    }
                }
        }
/*
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

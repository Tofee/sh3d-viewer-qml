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

    // performance reason
    property bool useOnlyDirectionalLight: true

    HomeModel {
        id: homeModel
    }
    WallModel {
        id: wallModel
    }
    RoomModel {
        id: roomModel
    }
    FurnitureModel {
        id: furnitureModel
    }
    ShelfModel {
        id: shelfModel
    }
    LightModel {
        id: lightModel
    }
    CameraModel {
        id: cameraModel

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
            lightProbe: Texture { source: ":/resources/little_paris_eiffel_tower_2k.hdr" }
            tonemapMode: SceneEnvironment.TonemapModeLinear
            clearColor: "#6060A0"
        }

        camera: PerspectiveCamera {
            id: mainCamera
        }

        DirectionalLight {
            color: "white"
            brightness: 2
            eulerRotation: Qt.vector3d(-80, -70, 0)
            use32BitShadowmap: true
            castsShadow: true
            shadowFactor: 50
            shadowMapQuality: DirectionalLight.ShadowMapQualityVeryHigh
            csmNumSplits: 0
            lockShadowmapTexels: false
            softShadowQuality: Light.PCF32
            pcfFactor: 2

            visible: useOnlyDirectionalLight
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
                leftSideColor: '#'+model.leftSideColor
                rightSideColor: '#'+model.rightSideColor
            }
        }

        // ----- rooms (floor & ceiling)------------------------------------
        Repeater3D {
            model: roomModel
            delegate: RoomDelegate {
                roomPointsModel: RoomPointsModel {
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
                furnitureSource: "sh3d:/"+model.modelFile

                materialModel: MaterialModel {
                    queryId: model.id
                    parentTag: "pieceOfFurniture"

                    Component.onCompleted: loadElementsFromDocumentWithQuery()
                }

                modelAngle: model.angle
                modelPitch: model.pitch
                modelRoll: model.roll
                modelX: model.x
                modelY: model.y
                modelHeight: model.height
                modelWidth: model.width
                modelDepth: model.depth
                modelElevation: (model.elevation || 0) // some furnitures don't have the elevation property
                modelEulerRotation: Sh3dHomeModel.getEulerAnglesFromRotationMatrix(model.modelRotation.split(' '));
            }
        }
        // ----- Furniture (Shelves) ------------------------------------------------
        Repeater3D {
            model: shelfModel
            delegate: FurnitureDelegate {
                furnitureSource: "sh3d:/"+model.modelFile

                materialModel: MaterialModel {
                    queryId: model.id
                    parentTag: "shelfUnit"

                    Component.onCompleted: loadElementsFromDocumentWithQuery()
                }

                modelAngle: model.angle
                modelPitch: model.pitch
                modelRoll: model.roll
                modelX: model.x
                modelY: model.y
                modelHeight: model.height
                modelWidth: model.width
                modelDepth: model.depth
                modelElevation: (model.elevation || 0) // some furnitures don't have the elevation property
                modelEulerRotation: Sh3dHomeModel.getEulerAnglesFromRotationMatrix(model.modelRotation.split(' '));
            }
        }


        // ----- Lights ---------------------------------------------------
        Repeater3D {
            model: lightModel
            delegate: LightDelegate {
                    furnitureSource: model.catalogId==='eTeks#halogenLightSource' ? "qrc:/resources/light-sphere.obj" : ("sh3d:/"+model.modelFile)

                    materialModel: MaterialModel {
                        queryId: model.id
                        parentTag: "light"

                        Component.onCompleted: loadElementsFromDocumentWithQuery()
                    }

                    modelAngle: model.angle
                    modelPitch: model.pitch
                    modelRoll: model.roll
                    modelX: model.x
                    modelY: model.y
                    modelHeight: model.height
                    modelWidth: model.width
                    modelDepth: model.depth
                    modelElevation: (model.elevation || 0) // some furnitures don't have the elevation property
                    modelEulerRotation: Sh3dHomeModel.getEulerAnglesFromRotationMatrix(model.modelRotation.split(' '));

                    lightPower: model.power
                    lightSourceModel: LightSourceModel {
                        queryLightId: model.id

                        Component.onCompleted: loadElementsFromDocumentWithQuery()
                    }

                    useOnlyDirectionalLight: root. useOnlyDirectionalLight
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

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

import "js/jscad-modeling.tofe.js" as JSCad
import "js/parseSvgPathData.min.js" as ParseSVG
import "js/DoorAndWindowsManager.js" as DoorAndWindowsManager;

Item {
    id: root

    // performance reason
    property bool useOnlyDirectionalLight: true || lightModel.count===0

    HomeModel {
        id: homeModel
    }
    WallModel {
        id: wallModel
    }
    RoomModel {
        id: roomModel
    }
    DoorModel {
        id: doorModel
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
                             mainCamera.eulerRotation = vec3_Y_UP((cam.yaw * 180 / Math.PI - 90)%360, 0, 180 - cam.pitch * 180 / Math.PI);
                             if (mainCamera.up.y < 0) {
                                 console.log("Making sure camera is standing up");
                                 mainCamera.lookAt(axisHelper);
                             }
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
            debugSettings: DebugSettings {
             //   materialOverride: DebugSettings.Normals
            }
            antialiasingMode: SceneEnvironment.MSAA
            backgroundMode: SceneEnvironment.SkyBox
            lightProbe: Texture {
                source: "qrc:///resources/little_paris_eiffel_tower_2k.hdr"
            }
            tonemapMode: SceneEnvironment.TonemapModeLinear
            clearColor: "#6060A0"
          //  adjustmentBrightness: 2
        }

        camera: PerspectiveCamera {
            id: mainCamera
        }

        DirectionalLight {
            color: "white"
            brightness: 0.5
            eulerRotation: Qt.vector3d(-80, -70, 0)
            shadowFactor: 10

            use32BitShadowmap: false
            castsShadow: true
            shadowMapQuality: DirectionalLight.ShadowMapQualityLow
            csmNumSplits: 0
            lockShadowmapTexels: false
            softShadowQuality: Light.PCF32

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
            id: wallRepeater3D
            property bool areCutOutDoorOrWindowsReady: false
            model: wallModel
            delegateModelAccess: DelegateModel.ReadOnly
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

                active: wallRepeater3D.areCutOutDoorOrWindowsReady
            }
        }

        // ----- rooms (floor & ceiling)------------------------------------
        Repeater3D {
            model: roomModel
            delegateModelAccess: DelegateModel.ReadOnly
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
            delegateModelAccess: DelegateModel.ReadOnly
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
            delegateModelAccess: DelegateModel.ReadOnly
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

        // ----- Furniture (Doors/Windows) ------------------------------------------------
        Repeater3D {
            model: doorModel
            delegateModelAccess: DelegateModel.ReadOnly
            delegate: FurnitureDelegate {
                furnitureSource: "sh3d:/"+model.modelFile

                materialModel: MaterialModel {
                    queryId: model.id
                    parentTag: "doorOrWindow"

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

                Component.onCompleted: {
                    let cutOutShape = model.cutOutShape;
                    if (model.cutOutShape === "" && model.wallCutOutOnBothSides === "true") {
                        cutOutShape = "M0,0 v1 h1 v-1 z";
                    }
                    DoorAndWindowsManager.addDoorOrWindowCutOut(cutOutShape, sceneTransform, JSCad, ParseSVG);
                    if (DoorAndWindowsManager.getListCutOutDoorOrWindow().length === doorModel.count) wallRepeater3D.areCutOutDoorOrWindowsReady = true;
                }
            }
        }

        // ----- Lights ---------------------------------------------------
        Repeater3D {
            model: lightModel
            delegateModelAccess: DelegateModel.ReadOnly
            delegate: LightDelegate {
                    property url undefined_url
                    furnitureSource: model.catalogId==='eTeks#halogenLightSource' ? undefined_url : ("sh3d:/"+model.modelFile)

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

                    useOnlyDirectionalLight: root.useOnlyDirectionalLight
                }
        }

    }
}

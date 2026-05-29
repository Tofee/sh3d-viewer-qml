// SceneLoader.qml
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils
import QtQml.XmlListModel
import QtQml.Models
import "."
import "models"

Item {
    id: root

    // performance reason
    property bool useOnlyDirectionalLight: false || lightModel.count===0

    HomeModel {
        id: homeModel
    }
    LevelModel {
        id: levelModel
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
            backgroundMode: SceneEnvironment.Color
            /*
            lightProbe: Texture {
                source: "qrc:///resources/kloofendal_48d_partly_cloudy_puresky_1k.hdr"
            }
            */
            tonemapMode: SceneEnvironment.TonemapModeLinear
            clearColor: "#6060A0"

            lightmapper: Lightmapper {
                source: "file:///tmp/sh3d_lightmaps.bin"
                // will attempt to load from :/lightmaps/lightmaps.bin at runtime
                // and write a file to lightmaps/lightmaps.bin when baking.
                samples: 16
            }
          //  adjustmentBrightness: 2
        }

        camera: PerspectiveCamera {
            id: mainCamera
        }

        DirectionalLight {
            color: "#fdf6e4"
            brightness: 1.0
            eulerRotation: Qt.vector3d(-80, -70, 0)
            shadowFactor: 10

            bakeMode: Light.BakeModeIndirect

            use32BitShadowmap: false
            castsShadow: true
            shadowMapQuality: DirectionalLight.ShadowMapQualityLow
            csmNumSplits: 0
            lockShadowmapTexels: false
            softShadowQuality: Light.PCF32
        }

        WasdController {
            controlledObject: mainCamera
        }

        AxisHelper {
            id: axisHelper
        }

        Loader3D {
            source: "SceneViews.qml"
            active: homeModel.initCompleted &&
                    levelModel.initCompleted &&
                    wallModel.initCompleted &&
                    roomModel.initCompleted &&
                    doorModel.initCompleted &&
                    furnitureModel.initCompleted &&
                    shelfModel.initCompleted &&
                    lightModel.initCompleted &&
                    cameraModel.initCompleted

            property HomeModel homeModel: homeModel
            property LevelModel levelModel: levelModel
            property WallModel wallModel: wallModel
            property RoomModel roomModel: roomModel
            property DoorModel doorModel: doorModel
            property FurnitureModel furnitureModel: furnitureModel
            property ShelfModel shelfModel: shelfModel
            property LightModel lightModel: lightModel
            property CameraModel cameraModel: cameraModel
        }
    }

    DebugView {
        source: mainView3D
    }
}

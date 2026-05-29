import QtQuick
import QtQuick3D
import QtQuick3D.Helpers

import "."
import "../models"
import "../js/LightsManager.js" as LightManager

Node {
    id: lightDelegate
    property alias furnitureSource: lightDelegateShape.furnitureSource
    property string modelId: lightDelegateShape.objectName
    property alias modelAngle: lightDelegateShape.modelAngle
    property alias modelPitch: lightDelegateShape.modelPitch
    property alias modelRoll: lightDelegateShape.modelRoll
    property alias modelX: lightDelegateShape.modelX
    property alias modelY: lightDelegateShape.modelY
    property alias modelHeight: lightDelegateShape.modelHeight
    property alias modelWidth: lightDelegateShape.modelWidth
    property alias modelDepth: lightDelegateShape.modelDepth
    property alias modelElevation: lightDelegateShape.modelElevation
    property alias modelEulerRotation: lightDelegateShape.modelEulerRotation
    property alias materialModel: lightDelegateShape.materialModel
    property alias levelElevation: lightDelegateShape.levelElevation

    property alias lightSourceModel: lightDelegateShape.lightSourceModel
    property alias lightPower: lightDelegateShape.lightPower

    property bool useOnlyDirectionalLight: false;

    FurnitureDelegate {
        id: lightDelegateShape
        property real lightPower
        property LightSourceModel lightSourceModel
    }

    Repeater3D {
        model: lightSourceModel
        delegate: Loader3D {
            id: pointLightDelegate
            active: false

            position: lightDelegateShape.position.plus(
                                vec3_Y_UP(lightDelegate.modelWidth*(model.x-0.5),
                                          lightDelegate.modelDepth*(model.y-0.5),
                                          levelElevation+lightDelegate.modelHeight*(model.z-0.5)))

            sourceComponent: PointLight {
                color: '#'+model.color
                brightness: 5*lightDelegate.lightPower

                // not possible to bake in the RuntimeLoader instances, so in the end it's veeery slow
                bakeMode: Light.BakeModeIndirect

//                use32BitShadowmap: true
                castsShadow: true
//                shadowFactor: 100
//                shadowMapQuality: DirectionalLight.ShadowMapQualityVeryHigh
//                softShadowQuality: Light.PCF32
//                pcfFactor: 2
            }

            Model {
                visible: false && pointLightDelegate.active
                source: "#Sphere"
                scale: Qt.vector3d(0.1,0.1,0.1)
                materials: [ PrincipledMaterial { baseColor: "red" } ]
            }

            Component.onCompleted: {
                // Qt Quick3D can handle some lights (around 10 for my hardware), so it cannot handle them all.
                // so only put a handful lights, not too near with one another
                if (LightManager.addNewLight(pointLightDelegate.scenePosition)) {
                    // activate this light
                    pointLightDelegate.active = !useOnlyDirectionalLight;
                }
            }
        }
    }
}

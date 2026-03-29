import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import "."
import "../models"

FurnitureDelegate {
    id: lightDelegate

    property real lightPower: 0.5
    property LightSourceModel lightSourceModel

    Repeater3D {
        model: lightSourceModel
        delegate: PointLight {
            id: pointLightDelegate
            color: '#'+model.color
            brightness: 1+lightDelegate.lightPower

            position: vec3_Y_UP(lightDelegate.modelWidth*(model.x-0.5),
                                lightDelegate.modelDepth*(model.y-0.5),
                                lightDelegate.modelHeight*(model.z-0.5))

            Component.onCompleted: console.log("PointLight at "+position+" brightness="+brightness+" color="+pointLightDelegate.color);
        }
    }
}

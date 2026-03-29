import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

Node {
    id: rootNode
    property alias furnitureSource: furnitureLoader.source
    property real modelAngle
    property real modelX
    property real modelY
    property real modelHeight
    property real modelWidth
    property real modelDepth
    property real modelElevation: 0

    visible: model.visible !== "false"
    Node {
        RuntimeLoader {
            id: furnitureLoader
            eulerRotation: Qt.vector3d(0,0,0)

            property vector3d posCenter: bounds.minimum.plus(bounds.maximum).times(0.5)
            property vector3d furnitureSize: bounds.maximum.minus(bounds.minimum)
/*
            Texture {
                id: myQtTexture
                source: "file:///home/chris/dev/projects/sh3d-viewer-qml/tests/DessinAppartComePrecis_remodelage/123/map-and-flame.jpg"
            }
*/
            onStatusChanged: {
                if (status == RuntimeLoader.Success) {
                    if (modelFile === "83/model.dae") {
                        // this is a DAE model, let's see what it holds
                        var lastChild = children[children.length-1];
                        // lastChild holds the materials, then the Model
                        //lastChild.children[1].baseColor = "#ffffff";
                        //lastChild.children[1].baseColorMap = myQtTexture;
                        for (let mat_i in lastChild.children) {
                            let material_i = lastChild.children[mat_i];
                            if (material_i.baseColorMap) /*QQuick3DPrincipledMaterial*/
                                console.log("source: "+mat_i+" "+material_i.baseColorMap.source);
                            else if (material_i.source)  /*QQuick3DTexture*/
                                console.log("source: "+mat_i+" "+material_i.source);
                            else
                                console.log("source: "+mat_i+" "+material_i+" "+material_i.baseColor);
                        }
                    }
                }
                else if (status == RuntimeLoader.Error) {
                    console.log("Furniture "+modelFile+" status: "+errorString);
                }
            }
        }
        position: furnitureLoader.posCenter.times(-1)
    }

    // Apply furniture's rotation, scale and position
    eulerRotation: vec3_Y_UP(0, 0, -modelAngle * 180 / Math.PI)
    scale: furnitureLoader.furnitureSize.length()>0 ?
               Qt.vector3d(modelWidth/furnitureLoader.furnitureSize.x,
                           modelHeight/furnitureLoader.furnitureSize.y,
                           modelDepth/furnitureLoader.furnitureSize.z) :
               Qt.vector3d(1,1,1)
    position: vec3_Y_UP(modelX, modelY, modelHeight/2 + modelElevation)
}

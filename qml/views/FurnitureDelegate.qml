import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

import "."
import "../models"

Node {
    id: rootNode
    property url furnitureSource
    property real modelAngle
    property real modelX
    property real modelY
    property real modelHeight
    property real modelWidth
    property real modelDepth
    property real modelElevation: 0

    property MaterialModel materialModel

    visible: model.visible !== "false"
    Node {
        RuntimeLoader {
            id: furnitureLoader
            eulerRotation: Qt.vector3d(0,0,0)
            source: rootNode.furnitureSource

            property vector3d posCenter: bounds.minimum.plus(bounds.maximum).times(0.5)
            property vector3d furnitureSize: bounds.maximum.minus(bounds.minimum)

            Instantiator {
                id: customMaterials
                model: materialModel
                delegate: PrincipledMaterial {
                    baseColor: model.color ? '#'+model.color : ''
                    baseColorMap: Texture {
                        source: model.texture_image ? Qt.resolvedUrl("sh3d:///"+model.texture_image) : ''
                    }
                    Component.onCompleted: {
                        let texturesOfMaterial = Sh3dHomeModel.runQuery(materialModel.query + "/texture", materialModel.skipNode);
                        if (texturesOfMaterial.length>0) {
                            // only consider the first one
                            //baseColorMap.scaleU = texturesOfMaterial[0].width;
                            //baseColorMap.scaleV = texturesOfMaterial[0].height;
                            baseColor = "#ffffff";
                            baseColorMap.source = "sh3d:/"+texturesOfMaterial[0].image;
                        }
                    }
                }
            }

            property bool materialsAllLoaded: false;
            Connections {
                target: materialModel
                function onLoadModelCompleted() {
                    furnitureLoader.materialsAllLoaded = true;
                    furnitureLoader.overrideMaterials();
                }
            }
            onStatusChanged: {
                 overrideMaterials();
            }

            function overrideMaterials() {
                if (status == RuntimeLoader.Success && materialsAllLoaded) {
                    var lastChild = children[children.length-1];
                    console.log("customMaterials.count = "+customMaterials.count+" lastChild.children.length="+lastChild.children.length);
                    // lastChild holds the materials, then the Model
                    for (let i=0; i<customMaterials.count && i<lastChild.children.length-1; ++i) {
                        console.log("Overriding material "+lastChild.children[i]+" with "+customMaterials.objectAt(i));
                        if (lastChild.children[i].hasOwnProperty('baseColorMap'))
                            lastChild.children[i].baseColorMap = customMaterials.objectAt(i).baseColorMap;
                        if (lastChild.children[i].hasOwnProperty('baseColor'))
                            lastChild.children[i].baseColor = customMaterials.objectAt(i).baseColor;
                        if (lastChild.children[i].hasOwnProperty('source')) /*QQuick3DTexture*/
                            lastChild.children[i].source = customMaterials.objectAt(i).baseColorMap.source;
                    }

                    if (furnitureLoader.source === "sh3d:/83/model.dae") {
                        // this is a DAE model, let's see what it holds
                        var lastChild = children[children.length-1];
                        // lastChild holds the materials, then the Model
                        //lastChild.children[1].baseColor = "#ffffff";
                        //lastChild.children[1].baseColorMap = myQtTexture;
                        for (let mat_i in lastChild.children) {
                            let material_i = lastChild.children[mat_i];
                            if (material_i.baseColorMap) /*QQuick3DPrincipledMaterial*/
                                console.log("source: "+mat_i+" "+material_i.baseColorMap.source);
                            else if (material_i.source)
                                console.log("source: "+mat_i+" "+material_i.source);
                            else
                                console.log("source: "+mat_i+" "+material_i+" "+material_i.baseColor);
                        }
                    }
                }
                else if (status == RuntimeLoader.Error) {
                    console.log("Furniture "+furnitureSource+" status: "+errorString);
                }
            }
        }
        position: furnitureLoader.posCenter.times(-1)
    }

    // Apply furniture's rotation, scale and position
    // TODO: apply modelRotation
    eulerRotation: vec3_Y_UP(0, 0, -modelAngle * 180 / Math.PI)
    scale: furnitureLoader.furnitureSize.length()>0 ?
               Qt.vector3d(modelWidth/furnitureLoader.furnitureSize.x,
                           modelHeight/furnitureLoader.furnitureSize.y,
                           modelDepth/furnitureLoader.furnitureSize.z) :
               Qt.vector3d(1,1,1)
    position: vec3_Y_UP(modelX, modelY, modelHeight/2 + modelElevation)
}

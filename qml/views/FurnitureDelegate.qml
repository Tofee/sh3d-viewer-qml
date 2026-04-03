import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

import "."
import "../models"

import sh3d_viewer_qml

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
    property vector3d modelEulerRotation: Qt.vector3d(0,0,0)

    property MaterialModel materialModel

    visible: model.visible !== "false"
    Node {
        Node {
            SH3DRuntimeLoader {
                id: furnitureLoader
                source: rootNode.furnitureSource

                property vector3d posCenter: bounds.minimum.plus(bounds.maximum).times(0.5)
                property vector3d furnitureSize: bounds.maximum.minus(bounds.minimum)

                property list<string> listMaterialNames: Sh3dHomeModel.retrieveMaterialNames(furnitureLoader.source)

                Instantiator {
                    id: customMaterials
                    model: materialModel
                    delegate: PrincipledMaterial {
                        property Texture pointed_texture: Texture {}

                        objectName: model.name
                        baseColor: model.color ? '#'+model.color : ''
                        Component.onCompleted: {
                            let texturesOfMaterial = Sh3dHomeModel.runQuery(materialModel.query + "/texture", materialModel.skipNode);
                            if (texturesOfMaterial.length>0) {
                                // only consider the first one
                                //baseColorMap.scaleU = texturesOfMaterial[0].width;
                                //baseColorMap.scaleV = texturesOfMaterial[0].height;
                                baseColor = "#ffffff";
                                baseColorMap = pointed_texture;
                                pointed_texture.source = "sh3d:/"+texturesOfMaterial[0].image;
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
                    if (!rootNode.modelEulerRotation.fuzzyEquals(Qt.vector3d(0,0,0))) {
                        console.log(rootNode.furnitureSource.toString() + " modelEulerRotation="+modelEulerRotation)
                    }
                     overrideMaterials();
                }

                function overrideMaterials() {
                    if (status == RuntimeLoader.Success && materialsAllLoaded) {
                        var lastChild = children[children.length-1];
                        // lastChild holds the materials, then the Model. But we only override materials !
                        let targetMaterialsIndices = [];
                        for (let i_all=0, i_mat=0; i_all<lastChild.children.length-1; ++i_all,++i_mat) {
                            targetMaterialsIndices[i_mat] = i_all;
                            if (!lastChild.children[i_all+1].hasOwnProperty('baseColorMap')) {
                                // Skipping next texture
                                ++i_all;
                            }
                        }

                        for (let i_from=0; i_from<customMaterials.count; ++i_from) {
                            //console.log("Overriding material "+lastChild.children[i]+" with "+customMaterials.objectAt(i));
                            let target_idx = listMaterialNames.indexOf(customMaterials.objectAt(i_from).objectName);
                            let target_idx_mat = targetMaterialsIndices[target_idx];

                            if (target_idx_mat>=0 && target_idx_mat<lastChild.children.length-1) {
                                if (lastChild.children[target_idx_mat].hasOwnProperty('baseColorMap'))
                                    lastChild.children[target_idx_mat].baseColorMap = customMaterials.objectAt(i_from).baseColorMap;
                                if (lastChild.children[target_idx_mat].hasOwnProperty('baseColor'))
                                    lastChild.children[target_idx_mat].baseColor = customMaterials.objectAt(i_from).baseColor;
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
        eulerRotation: rootNode.modelEulerRotation
        scale: furnitureLoader.furnitureSize.length()>0 ?
                   Qt.vector3d(1.0/furnitureLoader.furnitureSize.x,
                               1.0/furnitureLoader.furnitureSize.y,
                               1.0/furnitureLoader.furnitureSize.z) :
                   Qt.vector3d(1,1,1)
    }

    // Apply furniture's rotation, scale and position
    eulerRotation: vec3_Y_UP(0, 0, -modelAngle * 180 / Math.PI)
    scale: Qt.vector3d(modelWidth, modelHeight, modelDepth)
    position: vec3_Y_UP(modelX, modelY, modelHeight/2 + modelElevation)
}

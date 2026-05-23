import QtQuick
import QtQuick3D

PrincipledMaterial {
    property string textureLookupSelector

    roughness: 0.8;
    metalness: 0;
    baseColorMap: Texture { }
    Component.onCompleted: {
        let texturesOfMaterial = Sh3dHomeModel.runQuery(textureLookupSelector, "none");
        if (texturesOfMaterial.length>0) {
            // only consider the first one
            if (texturesOfMaterial[0].hasOwnProperty('scale')) {
                baseColorMap.scaleU = texturesOfMaterial[0].scale;
                baseColorMap.scaleV = texturesOfMaterial[0].scale;
            }
            baseColor = "#ffffff";
            baseColorMap.source = "sh3d:/"+texturesOfMaterial[0].image;
        }
    }
}
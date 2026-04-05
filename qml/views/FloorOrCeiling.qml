import QtQuick
import QtQuick3D
import QtQuick3D.Helpers

import "../js/earcut.js" as EarCut

Model {
    id: floorOrCeilingModel
    property real thickness: 10
    property variant roomPoints
    property int nbPoints: roomPoints ? roomPoints.length : 0

    property string roomId
/*
    usedInBakedLighting: true
    bakedLightmap: BakedLightmap {
        enabled: true
        key: "wholeScene"
    }
*/
    materials: [
        PrincipledMaterial {
            baseColorMap: Texture {}
            Component.onCompleted: {
                let texturesOfMaterial = Sh3dHomeModel.runQuery("/room[@id='"+floorOrCeilingModel.roomId+"']/texture", "none");
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
    ]

    geometry: ProceduralMesh {
        id: mainMesh
        property var meshArrays: generateRoomSurface(roomPoints, thickness)
        positions: meshArrays.verts
        normals: meshArrays.normals
        uv0s: meshArrays.uvs
        indexes: meshArrays.indices
        subsets: [
            ProceduralMeshSubset { count: mainMesh.meshArrays.nbEarcutIndices; offset: 0 },  /* above */
            ProceduralMeshSubset { count: mainMesh.meshArrays.nbEarcutIndices; offset: mainMesh.meshArrays.nbEarcutIndices },  /* below */
            ProceduralMeshSubset { count: floorOrCeilingModel.nbPoints*2*3; offset: mainMesh.meshArrays.nbEarcutIndices*2 }  /* whole border */
        ]

        function generateRoomSurface(roomPoints: variant, thickness: real): variant {
            let verts = []
            let normals = []
            let uvs = []
            let indices = []
            let i = 0;

            if (!roomPoints || roomPoints.length < 3 )
                return { verts: verts, normals: normals, uvs: uvs, indices: indices }

            let maxExtent = Qt.vector2d(0,0);
            let minExtent = Qt.vector2d(0,0);

            for (i = 0; i < roomPoints.length; ++i) {
                verts.push(vec3_Y_UP(roomPoints[i].x, roomPoints[i].y, -thickness)); //below
                verts.push(vec3_Y_UP(roomPoints[i].x, roomPoints[i].y, 0));          //above

                normals.push(vec3_Y_UP(0, 0, -1));
                normals.push(vec3_Y_UP(0, 0, 1));

                maxExtent.x = Math.max(maxExtent.x, roomPoints[i].x)
                maxExtent.y = Math.max(maxExtent.y, roomPoints[i].y)
                minExtent.x = Math.min(minExtent.x, roomPoints[i].x)
                minExtent.y = Math.min(minExtent.y, roomPoints[i].y)
            }

            let widthSurface  = maxExtent.x - minExtent.x;
            let heightSurface = maxExtent.y - minExtent.y;

            for (i = 0; i < roomPoints.length; ++i) {
                // U and V will correspond to the relative abs and ord, normalized for a 200cmx200cm surface
                uvs.push(Qt.vector2d((roomPoints[i].x-minExtent.x) / widthSurface, (roomPoints[i].y-minExtent.y) / heightSurface));
                uvs.push(Qt.vector2d((roomPoints[i].x-minExtent.x) / widthSurface, (roomPoints[i].y-minExtent.y) / heightSurface));
            }

            // Create a mesh for the main surface
            let flatRoomPointsArray = roomPoints.reduce((accArray, roomPoint) => {
                                                               accArray.push(Number(roomPoint.x), Number(roomPoint.y));
                                                               return accArray;
                                                           }, [])
            const earcutIndices = EarCut.earcut(flatRoomPointsArray);

            // Create the indices. We want 3 sub meshes: above, below, and whole border
            // Adjust order to be counter-clockwise
            /* below: earcut indices should point to the even vertices and the triangle should be opposite */
            indices.push(...earcutIndices.map((idx) => idx*2)); // beware: reverse() modifies the array itself !
            /* above: earcut indices should point to the odd vertices */
            indices.push(...earcutIndices.reverse().map((idx) => idx*2+1));
            /* whole border */
            for (i = 0; i < roomPoints.length-1; ++i) {
                indices.push(i*2 + 1, i*2, (i+1)*2);
                indices.push((i+1)*2, (i+1)*2 + 1, i*2 + 1);
            }
            // last point, wrap up border
            // nb: i equals roomPoints.length-1 because of the for loop
            indices.push(i*2 + 1, i*2, 0);
            indices.push(0, 0 + 1, i*2 + 1);

            return { verts: verts, normals: normals, uvs: uvs, indices: indices, nbEarcutIndices: earcutIndices.length }
        }
    }
}

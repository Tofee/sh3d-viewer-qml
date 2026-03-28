import QtQuick
import QtQuick3D
import QtQuick3D.Helpers

Model {
    id: floorOrCeilingModel
    property real thickness: 10
    property variant roomPoints
    property int nbPoints: roomPoints ? roomPoints.length : 0

    geometry: ProceduralMesh {
        property bounds meshBounds;
        property var meshArrays: generateRoomSurface(roomPoints, thickness)
        positions: meshArrays.verts
        normals: meshArrays.normals
        uv0s: meshArrays.uvs
        indexes: meshArrays.indices
        subsets: [ ProceduralMeshSubset { count: 2*3; offset: 0 },  /* left */
            ProceduralMeshSubset { count: 2*3; offset: 2*3 },  /* right */
            ProceduralMeshSubset { count: floorOrCeilingModel.nbPoints*2*3; offset: 4*3 },  /* above */
            ProceduralMeshSubset { count: floorOrCeilingModel.nbPoints*2*3; offset: 4*3+floorOrCeilingModel.nbPoints*2*3 },  /* below */
            ProceduralMeshSubset { count: floorOrCeilingModel.nbPoints*2*3; offset: 4*3+floorOrCeilingModel.nbPoints*2*2*3 },  /* inside */
            ProceduralMeshSubset { count: floorOrCeilingModel.nbPoints*2*3; offset: 4*3+floorOrCeilingModel.nbPoints*2*3*3 }   /* outside */
        ]

        function generateArcWall(roomPoints: variant, thickness: real): variant {
            let verts = []
            let normals = []
            let uvs = []
            let indices = []
            let i = 0;

            meshBounds.maximum = Qt.vector3d(0,0,thickness);;
            meshBounds.minimum = Qt.vector3d(0,0,0);

            for (i = 0; i < roomPoints.length; ++i) {
                verts.push(vec3_Y_UP(roomPoints[i].x, roomPoints[i].y, 0));
                verts.push(vec3_Y_UP(roomPoints[i].x, roomPoints[i].y, thickness));

                meshBounds.maximum.x = Math.max(meshBounds.maximum.x, roomPoints[i].x)
                meshBounds.maximum.y = Math.max(meshBounds.maximum.y, roomPoints[i].x)
                meshBounds.minimum.x = Math.min(meshBounds.minimum.x, roomPoints[i].x)
                meshBounds.minimum.y = Math.min(meshBounds.minimum.y, roomPoints[i].x)
            }

            let widthSurface  = meshBounds.maximum.x - meshBounds.minimum.x;
            let heightSurface = meshBounds.maximum.y - meshBounds.minimum.y;

            for (i = 0; i < roomPoints.length; ++i) {
                // U and V will correspond to the relative abs and ord, normalized to 1
                uvs.push(Qt.vector2d((roomPoints[i].x-meshBounds.minimum.x) / widthSurface, (roomPoints[i].y-meshBounds.minimum.y) / heightSurface));
                uvs.push(Qt.vector2d((roomPoints[i].x-meshBounds.minimum.x) / widthSurface, (roomPoints[i].y-meshBounds.minimum.y) / heightSurface));
            }

            // Create the indices. We want 6 sub meshes: left side, right side, above, below, interior, exterior
            // Adjust order to be counter-clockwise
            /* left */
            indices.push(0, 1, 2);
            indices.push(2, 3, 0);
            /* right */
            indices.push(nbPoints*4 + 1, nbPoints*4 + 0, nbPoints*4 + 3);
            indices.push(nbPoints*4 + 3, nbPoints*4 + 2, nbPoints*4 + 1);
            /* above */
            for (i = 0; i < nbPoints; ++i) {
                indices.push(i*4 + 1, (i+1)*4 + 1, (i+1)*4 + 2);
                indices.push((i+1)*4 + 2, i*4 + 2, i*4 + 1);
            }
            /* below */
            for (i = 0; i < nbPoints; ++i) {
                indices.push((i+1)*4 + 0, i*4 + 0, (i+1)*4 + 3);
                indices.push(i*4 + 3, (i+1)*4 + 3, i*4 + 0);
            }
            /* inside */
            for (i = 0; i < nbPoints; ++i) {
                indices.push(i*4 + 0, (i+1)*4 + 0, (i+1)*4 + 1);
                indices.push((i+1)*4 + 1, i*4 + 1, i*4 + 0);
            }
            /* outside */
            for (i = 0; i < nbPoints; ++i) {
                indices.push(i*4 + 3, i*4 + 2, (i+1)*4 + 3);
                indices.push((i+1)*4 + 2, (i+1)*4 + 3, i*4 + 2);
            }

            return { verts: verts, normals: normals, uvs: uvs, indices: indices }
        }
    }
}

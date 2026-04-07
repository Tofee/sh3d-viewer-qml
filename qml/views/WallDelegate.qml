import QtQuick
import QtQuick3D
import QtQuick3D.Helpers

import "../js/jscad-modeling.min.js" as JSCad
import "../js/parseSvgPathData.min.js" as ParseSVG

Loader3D {
    property real xStart
    property real xEnd
    property real yStart
    property real yEnd
    property real thickness
    property real height
    property real arcExtent
    property color leftSideColor
    property color rightSideColor

    sourceComponent: (arcExtent && arcExtent>0) ? arcWallModel : simpleWallModel

    property Component arcWallModelComp : Component {
        id: arcWallModel
        Model {
            /*
            usedInBakedLighting: true
            bakedLightmap: BakedLightmap {
                enabled: true
                key: "wall"
            }
            */

            materials: [ PrincipledMaterial { baseColor: "white" },
                         PrincipledMaterial { baseColor: "white" },
                         PrincipledMaterial { baseColor: "white" },
                         PrincipledMaterial { baseColor: "white" },
                         PrincipledMaterial { baseColor: leftSideColor },
                         PrincipledMaterial { baseColor: rightSideColor } ]
            geometry: ProceduralMesh {
                id: arcWallMesh
                property int  nbPoints: 10
                property var meshArrays: generateArcWall(xStart, yStart, xEnd, yEnd, arcExtent, thickness, height, nbPoints)
                positions: meshArrays.verts
                normals: meshArrays.normals
                uv0s: meshArrays.uvs
                indexes: meshArrays.indices
                subsets: [ ProceduralMeshSubset { count: 2*3; offset: 0 },  /* left */
                    ProceduralMeshSubset { count: 2*3; offset: 2*3 },  /* right */
                    ProceduralMeshSubset { count: arcWallMesh.nbPoints*2*3; offset: 4*3 },  /* above */
                    ProceduralMeshSubset { count: arcWallMesh.nbPoints*2*3; offset: 4*3+arcWallMesh.nbPoints*2*3 },  /* below */
                    ProceduralMeshSubset { count: arcWallMesh.nbPoints*2*3; offset: 4*3+arcWallMesh.nbPoints*2*2*3 },  /* inside */
                    ProceduralMeshSubset { count: arcWallMesh.nbPoints*2*3; offset: 4*3+arcWallMesh.nbPoints*2*3*3 }   /* outside */
                ]

                function generateArcWall(xStart: real, yStart: real, xEnd: real, yEnd: real, arcExtent: real, wallThickness: real, wallHeight: real, nbPoints: int): variant {
                    let verts = []
                    let normals = []
                    let uvs = []
                    let indices = []
                    let i = 0;

                    let wallStart2D = Qt.vector2d(xStart, yStart);
                    let wallEnd2D   = Qt.vector2d(xEnd, yEnd);
                    let wallVector  = wallEnd2D.minus(wallStart2D);
                    let medianLength = (wallVector.length()/2)/Math.atan(arcExtent/2);
                    let medianVector = Qt.vector2d(-wallVector.y,wallVector.x).times(medianLength/wallVector.length());
                    let posOriginArc = wallStart2D.plus(wallVector.times(0.5)).plus(medianVector);

                    let firstRadiusVector = wallStart2D.minus(posOriginArc);
                    let lastRadiusVector = wallStart2D.minus(posOriginArc);
                    let arcRadius = firstRadiusVector.length();
                    // x′=xcosθ − ysinθ
                    // y'=xsinθ + ycosθ

                    for (i = 0; i <= nbPoints; ++i) {
                        let rotatedRadiusVector = wallStart2D.minus(posOriginArc);;
                        if (i === nbPoints) rotatedRadiusVector = wallEnd2D.minus(posOriginArc);
                        if (i > 0 && i < nbPoints) {
                            let angleRot = i*arcExtent/(nbPoints+1);
                            rotatedRadiusVector.x = firstRadiusVector.x*Math.cos(angleRot) - firstRadiusVector.y*Math.sin(angleRot);
                            rotatedRadiusVector.y = firstRadiusVector.x*Math.sin(angleRot) + firstRadiusVector.y*Math.cos(angleRot);
                        }
                        let arcPointInside = posOriginArc.plus(rotatedRadiusVector.times((arcRadius-wallThickness/2)/arcRadius));
                        let arcPointOutside = posOriginArc.plus(rotatedRadiusVector.times((arcRadius+wallThickness/2)/arcRadius));

                        verts.push(vec3_Y_UP(arcPointInside.x, arcPointInside.y, 0));
                        verts.push(vec3_Y_UP(arcPointInside.x, arcPointInside.y, wallHeight));
                        verts.push(vec3_Y_UP(arcPointOutside.x, arcPointOutside.y, wallHeight));
                        verts.push(vec3_Y_UP(arcPointOutside.x, arcPointOutside.y, 0));

                        normals.push(vec3_Y_UP(-rotatedRadiusVector.x, -rotatedRadiusVector.y, -arcRadius).normalized());
                        normals.push(vec3_Y_UP(-rotatedRadiusVector.x, -rotatedRadiusVector.y, arcRadius).normalized());
                        normals.push(vec3_Y_UP(rotatedRadiusVector.x, rotatedRadiusVector.y, arcRadius).normalized());
                        normals.push(vec3_Y_UP(rotatedRadiusVector.x, rotatedRadiusVector.y, -arcRadius).normalized());

                        uvs.push(Qt.vector2d(i / nbPoints, 0));
                        uvs.push(Qt.vector2d(i / nbPoints, 1));
                        uvs.push(Qt.vector2d(i / nbPoints, 1));
                        uvs.push(Qt.vector2d(i / nbPoints, 0));
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
    }
    property Component simpleWallComp: Component {
        id: simpleWallModel
        Model {
/*
            usedInBakedLighting: true
            bakedLightmap: BakedLightmap {
                enabled: true
                key: "wholeScene"
            }
*/
            // Simple rectangular cube for a wall
            geometry: ProceduralMesh {
                id: arcWallMesh
                property int  nbPoints: 10
                property var meshArrays: generateWall(xStart, yStart, xEnd, yEnd, thickness, height, nbPoints)
                positions: meshArrays.verts
                normals: meshArrays.normals
                uv0s: meshArrays.uvs
                indexes: meshArrays.indices

                function generateWall(xStart: real, yStart: real, xEnd: real, yEnd: real, wallThickness: real, wallHeight: real, nbPoints: int): variant {
                    let verts = []
                    let normals = []
                    let uvs = []
                    let indices = []
                    let i = 0;

                    let wallLine = vec3_Y_UP(xEnd-xStart, yEnd-yStart, 0);
                    let wallPerpendicularVector = vec3_Y_UP(0, 0, 1).crossProduct(wallLine.normalized());

                    try {
                        // keep in mind that we are using "Y-Up" display, so height goes along Y
                        let straightWall = JSCad.modeling.primitives.cuboid({size: [wallLine.length(), wallHeight, wallThickness]})

                        // TODO: translate the wall and/or the windows to the right positions !
                        //       by default, JSCad objects are centered on the origin

                        let windowPath = ParseSVG.parseSvgPathData("M0,0 v1 h1 v-1 z");
                        let windowPoints = windowPath.map((p) => [p.x*wallLine.length(), p.y*wallHeight]);
                        windowPoints.slice(1).reverse();
                        let windowPoly = JSCad.modeling.primitives.polygon({ points: windowPoints })

                        let window3D = JSCad.modeling.extrusions.extrudeLinear({height: wallThickness}, windowPoly);
                        let wallWithoutWindow = JSCad.modeling.booleans.subtract(straightWall, window3D);

                        //rotate the wall on Y axis
                        let angle = Math.atan2(wallLine.y, wallLine.x)
                        let rotatedWall = JSCad.modeling.transforms.rotateY(angle, wallWithoutWindow);

                        let vertices = [];
                    }
                    catch(e) {
                        let errorString = e.toString();
                        console.assert(false, "substract error: "+e);
                    }

                    return { verts: verts, normals: normals, uvs: uvs, indices: indices }
                }
            }

            materials: [ PrincipledMaterial { baseColor: "white"; roughness: 0 },
                         PrincipledMaterial { baseColor: "white" },
                         PrincipledMaterial { baseColor: leftSideColor },
                         PrincipledMaterial { baseColor: rightSideColor },
                         PrincipledMaterial { baseColor: "white" },
                         PrincipledMaterial { baseColor: "white" } ]

            // Compute centre + orientation from the two end points
            property real dx: xEnd - xStart
            property real dy: yEnd - yStart
            property real length: Math.sqrt(dx * dx + dy * dy)
            property real angle: Math.atan2(dy, dx) * 180 / Math.PI

            position: vec3_Y_UP((xStart + xEnd) / 2, (yStart + yEnd) / 2, height / 2)
            scale: vec3_Y_UP(length / 100, thickness / 100, height / 100)
            eulerRotation: vec3_Y_UP(0, 0, angle)
        }
    }
}

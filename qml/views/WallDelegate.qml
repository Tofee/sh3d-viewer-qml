import QtQuick
import QtQuick3D
import QtQuick3D.Helpers

import "../models"

import "../js/jscad-modeling.tofe.js" as JSCad
import "../js/earcut.js" as EarCut
import "../js/DoorAndWindowsManager.js" as DoorAndWindowsManager;

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
                id: straightWallMesh
                property var meshArrays: generateWall(xStart, yStart, xEnd, yEnd, thickness, height)
                positions: meshArrays.verts
                normals: meshArrays.normals
                uv0s: meshArrays.uvs
                indexes: meshArrays.indices
                subsets: [
                    ProceduralMeshSubset { count: straightWallMesh.meshArrays.nbIndicesSideLeft; offset: 0 },  /* left */
                    ProceduralMeshSubset { count: straightWallMesh.meshArrays.nbIndicesSideRight; offset: straightWallMesh.meshArrays.nbIndicesSideLeft },
                    ProceduralMeshSubset { count: straightWallMesh.meshArrays.nbIndicesSideOther; offset: straightWallMesh.meshArrays.nbIndicesSideLeft+straightWallMesh.meshArrays.nbIndicesSideRight }
                ]

                function _retrieveWallSideData(wallPolygons: variant, wantedWallNormal: vector3d): variant {
                    let wallPolygonsIndices = [];
                    for (let poly_i=0; poly_i<wallPolygons.length; ++poly_i) {
                        if (!wallPolygons[poly_i].vertices || wallPolygons[poly_i].vertices.length<3) continue;
                        let polyEdge1 = Qt.vector3d(...wallPolygons[poly_i].vertices[1]).minus(Qt.vector3d(...wallPolygons[poly_i].vertices[0]));
                        let polyEdge2 = Qt.vector3d(...wallPolygons[poly_i].vertices[2]).minus(Qt.vector3d(...wallPolygons[poly_i].vertices[1]));
                        const wallSidePolyNormal = polyEdge1.crossProduct(polyEdge2).normalized();

                        if (wallSidePolyNormal.dotProduct(wantedWallNormal) > 0.99) {
                            wallPolygonsIndices.push(poly_i);
                        }
                    }
                    return wallPolygonsIndices;
                }
                function _addWallSide(wallPolygon: variant, wallNormal: vector3d, wallBBox: variant, indices: variant, verts: variant, normals: variant, uvs: variant) {
                    const existingVertsLength = verts.length;
                    let data = wallPolygon.vertices.flat();
                    //earcut only works on the dimensions x and y, whatever we give it
                    //so if polygon's normal is along X, eliminate X by shifting the array by one
                    let normalOnX = (wallNormal.fuzzyEquals(Qt.vector3d(1,0,0)) || wallNormal.fuzzyEquals(Qt.vector3d(-1,0,0)));
                    let normalOnY = (wallNormal.fuzzyEquals(Qt.vector3d(0,1,0)) || wallNormal.fuzzyEquals(Qt.vector3d(0,-1,0)));
                    let dataXY = data;
                    if (normalOnX)
                    {
                        // make earcut work on YZ
                        dataXY = wallPolygon.vertices.map((vertex) => {return [vertex[1], vertex[2], vertex[0]]}).flat();
                    }
                    else if (normalOnY)
                    {
                        // make earcut work on ZX
                        dataXY = wallPolygon.vertices.map((vertex) => {return [vertex[2], vertex[0], vertex[1]]}).flat();
                    }
                    // let triangulatedPolygon = JSCad.modeling.modifiers.generalize({triangulate: true}, wallPolygon);
                    let triangles = EarCut.earcut(dataXY, null, 3);
                    indices.push(...triangles.map(i=>(i+existingVertsLength)));

                    for (let i=0; i<wallPolygon.vertices.length; ++i) {
                        verts.push(Qt.vector3d(wallPolygon.vertices[i][0],wallPolygon.vertices[i][1],wallPolygon.vertices[i][2]));
                        normals.push(wallNormal);
                        if (normalOnX) {
                            uvs.push(Qt.vector2d((wallPolygon.vertices[i][2]-wallBBox[0][2])/(wallBBox[1][2]-wallBBox[0][2]),
                                                 (wallPolygon.vertices[i][1]-wallBBox[0][1])/(wallBBox[1][1]-wallBBox[0][1])));
                        } else {
                            uvs.push(Qt.vector2d((wallPolygon.vertices[i][0]-wallBBox[0][0])/(wallBBox[1][0]-wallBBox[0][0]),
                                                 (wallPolygon.vertices[i][1]-wallBBox[0][1])/(wallBBox[1][1]-wallBBox[0][1])));
                        }
                    }
                }

                function _canIntersect(geomBBox1, geomBBox2) {
                    const minIntersect = {
                        x: Math.max(geomBBox1[0][0], geomBBox2[0][0]),
                        y: Math.max(geomBBox1[0][1], geomBBox2[0][1]),
                        z: Math.max(geomBBox1[0][2], geomBBox2[0][2])
                    }
                    const maxIntersect = {
                        x: Math.min(geomBBox1[1][0], geomBBox2[1][0]),
                        y: Math.min(geomBBox1[1][1], geomBBox2[1][1]),
                        z: Math.min(geomBBox1[1][2], geomBBox2[1][2])
                    }
                    // Intersection if volume is positive
                    return (maxIntersect.x > minIntersect.x &&
                            maxIntersect.y > minIntersect.y &&
                            maxIntersect.z > minIntersect.z);
                }

                function generateWall(xStart: real, yStart: real, xEnd: real, yEnd: real, wallThickness: real, wallHeight: real): variant {
                    let _verts = []
                    let _normals = []
                    let _uvs = []
                    let _indices = []
                    let i = 0;
                    let _nbIndicesSideLeft = 0;
                    let _nbIndicesSideRight = 0;

                    let wallLine = vec3_Y_UP(xEnd-xStart, yEnd-yStart, 0);
                    let wallPerpendicularVector = vec3_Y_UP(0, 0, 1).crossProduct(wallLine.normalized());

                    try {
                        // keep in mind that we are using "Y-Up" display, so height goes along Y
                        let straightWall = JSCad.modeling.primitives.cuboid({size: [wallLine.length(), wallHeight, wallThickness]})

                        //rotate the wall on Y axis
                        let angle = Math.atan2(wallLine.z, wallLine.x)
                        let rotatedWall = JSCad.modeling.transforms.rotateY(angle, straightWall);

                        // translate the wall to its correct position
                        let positionedWall = JSCad.modeling.transforms.translate([(xStart + xEnd) / 2, wallHeight / 2, (yStart + yEnd) / 2], rotatedWall);

                        let wallWithoutWindow = positionedWall;
                        //console.log("wall: "+xStart+","+yStart+" -> "+xEnd+","+yEnd);

                        const listCutOutDoorOrWindow = DoorAndWindowsManager.getListCutOutDoorOrWindow();

                        const wallBBox = JSCad.modeling.measurements.measureBoundingBox(wallWithoutWindow);
                        const cutOutsBBox = JSCad.modeling.measurements.measureBoundingBox(...listCutOutDoorOrWindow);

                        for( i=0; i<listCutOutDoorOrWindow.length; ++i) {
                            // test intersection of bounding boxes first, as we often get a crash when substracting non intersecting geometries
                            if (!_canIntersect(wallBBox, cutOutsBBox[i])) continue;
                            wallWithoutWindow = JSCad.modeling.booleans.subtract(wallWithoutWindow, listCutOutDoorOrWindow[i]);
                        }

                        // snap to grid and convert to triangles
                        const polygons = JSCad.modeling.geometries.geom3.toPolygons(wallWithoutWindow);

                        // determine the polygon having the most vertices, and whose normal is aligned with wallPerpendicularVector
                        //  -> mesh it with earcut
                        //  -> add its vertices and triangles to the list, normals should be wallPerpendicularVector.normalized()
                        let foundWallIndicesSideLeft = _retrieveWallSideData(polygons, wallPerpendicularVector);
                        foundWallIndicesSideLeft.forEach(idx => {
                            _addWallSide(polygons[idx], wallPerpendicularVector, wallBBox, _indices, _verts, _normals, _uvs);
                        });
                        _nbIndicesSideLeft = _indices.length;

                        // determine the second polygon with most vertices, normal opposite to wallPerpendicularVector
                        //  -> mesh it with earcut
                        //  -> add its vertices and triangles to the list, normals should be -wallPerpendicularVector.normalized()
                        let foundWallIndicesSideRight = _retrieveWallSideData(polygons, wallPerpendicularVector.times(-1));
                        foundWallIndicesSideRight.forEach(idx => {
                            _addWallSide(polygons[idx], wallPerpendicularVector.times(-1), wallBBox, _indices, _verts, _normals, _uvs);
                        });
                        _nbIndicesSideRight = _indices.length - _nbIndicesSideLeft;

                        // now for the rest of polygons:
                        //  -> mesh it with earcut
                        //  -> add vertices and triangles to the list, with normals given per polygon
                        [ wallLine.normalized(),           /* front */
                          wallLine.normalized().times(-1), /* back  */
                          vec3_Y_UP(0, 0,  1),             /* above */
                          vec3_Y_UP(0, 0, -1) ]            /* below */
                        .forEach(sideNormal => {
                            let foundWallIndicesSideOther = _retrieveWallSideData(polygons, sideNormal);
                            foundWallIndicesSideOther.forEach(idx => {
                                _addWallSide(polygons[idx], sideNormal, wallBBox, _indices, _verts, _normals, _uvs);
                            });
                        });
                    }
                    catch(e) {
                        let errorString = e.toString();
                        console.warn(false, "generateWall error: "+e);
                    }

                    return { verts: _verts, normals: _normals, uvs: _uvs, indices: _indices,
                             nbIndicesSideLeft: _nbIndicesSideLeft,
                             nbIndicesSideRight: _nbIndicesSideRight,
                             nbIndicesSideOther: _indices.length-_nbIndicesSideLeft-_nbIndicesSideRight
                           }
                }
            }

            materials: [ PrincipledMaterial { roughness: 0.8; metalness: 0; baseColor: leftSideColor },
                         PrincipledMaterial { roughness: 0.8; metalness: 0; baseColor: rightSideColor },
                         PrincipledMaterial { roughness: 1; metalness: 0; baseColor: "white" } ]
        }
    }
}

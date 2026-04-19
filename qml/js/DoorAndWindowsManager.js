.pragma library

var listCutOutDoorOrWindow = [];

function addDoorOrWindowCutOut(cutOutSvgPath, sceneTransform, JSCad, ParseSVG) {
    let windowPath = ParseSVG.parseSvgPathData(cutOutSvgPath);
    let windowPoints = windowPath.map((p) => [p.x-0.5, p.y-0.5]);
    windowPoints.reverse().slice(1);
    let windowPoly = JSCad.modeling.primitives.polygon({ points: windowPoints })

    let window3D = JSCad.modeling.transforms.translate([0, 0, -0.5], JSCad.modeling.extrusions.extrudeLinear({height: 1}, windowPoly));

    // Now apply the scene transformation on the window
    const modelQtMat4 = sceneTransform
    const sceneMat4 = JSCad.modeling.maths.mat4.fromValues(
            modelQtMat4.m11, modelQtMat4.m21, modelQtMat4.m31, modelQtMat4.m41,
            modelQtMat4.m12, modelQtMat4.m22, modelQtMat4.m32, modelQtMat4.m42,
            modelQtMat4.m13, modelQtMat4.m23, modelQtMat4.m33, modelQtMat4.m43,
            modelQtMat4.m14, modelQtMat4.m24, modelQtMat4.m34, modelQtMat4.m44
          )

    let rotatedWindow = JSCad.modeling.transforms.transform(sceneMat4, window3D);

    listCutOutDoorOrWindow.push(rotatedWindow);
}

function getListCutOutDoorOrWindow() {
    return listCutOutDoorOrWindow;
}

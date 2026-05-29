import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

import "views"
import "models"

import "js/jscad-modeling.tofe.js" as JSCad
import "js/parseSvgPathData.min.js" as ParseSVG
import "js/DoorAndWindowsManager.js" as DoorAndWindowsManager

Node {
    // ----- Walls ----------------------------------------------------
    Repeater3D {
        id: wallRepeater3D
        property bool areCutOutDoorOrWindowsReady: false
        model: wallModel
        delegateModelAccess: DelegateModel.ReadOnly
        delegate: WallDelegate {
            wallId: model.id
            xStart: model.xStart
            xEnd: model.xEnd
            yStart: model.yStart
            yEnd: model.yEnd
            thickness: model.thickness
            height: model.height
            arcExtent: model.arcExtent
            leftSideColor: '#'+model.leftSideColor
            rightSideColor: '#'+model.rightSideColor
            levelElevation: levelModel.getElevationForId(model.level)

            active: wallRepeater3D.areCutOutDoorOrWindowsReady
        }
    }

    // ----- rooms (floor & ceiling)------------------------------------
    Repeater3D {
        model: roomModel
        delegateModelAccess: DelegateModel.ReadOnly
        delegate: RoomDelegate {
            roomPointsModel: RoomPointsModel {
                queryRoomId: model.id

                Component.onCompleted: loadElementsFromDocumentWithQuery()
            }

            roomId: model.id
            floorVisible: model.floorVisible || model.areaVisible
            floorColor: model.floorColor
            floorShininess: model.floorShininess
            ceilingVisible: model.ceilingVisible
            ceilingColor: model.ceilingColor
            ceilingShininess: model.ceilingShininess
            ceilingFlat: model.ceilingFlat
            roomPoints: roomModel.points
            levelElevation: levelModel.getElevationForId(model.level)
        }
    }

    // ----- Furniture ------------------------------------------------
    Repeater3D {
        model: furnitureModel
        delegateModelAccess: DelegateModel.ReadOnly
        delegate: FurnitureDelegate {
            furnitureSource: "sh3d:/"+model.modelFile
            modelId: model.id

            materialModel: MaterialModel {
                queryId: model.id
                parentTag: "pieceOfFurniture"

                Component.onCompleted: loadElementsFromDocumentWithQuery()
            }

            modelAngle: model.angle
            modelPitch: model.pitch
            modelRoll: model.roll
            modelX: model.x
            modelY: model.y
            modelHeight: model.height
            modelWidth: model.width
            modelDepth: model.depth
            modelElevation: (model.elevation || 0) // some furnitures don't have the elevation property
            levelElevation: levelModel.getElevationForId(model.level)
            modelEulerRotation: Sh3dHomeModel.getEulerAnglesFromRotationMatrix(model.modelRotation.split(' '));
        }
    }
    // ----- Furniture (Shelves) ------------------------------------------------
    Repeater3D {
        model: shelfModel
        delegateModelAccess: DelegateModel.ReadOnly
        delegate: FurnitureDelegate {
            furnitureSource: "sh3d:/"+model.modelFile
            modelId: model.id

            materialModel: MaterialModel {
                queryId: model.id
                parentTag: "shelfUnit"

                Component.onCompleted: loadElementsFromDocumentWithQuery()
            }

            modelAngle: model.angle
            modelPitch: model.pitch
            modelRoll: model.roll
            modelX: model.x
            modelY: model.y
            modelHeight: model.height
            modelWidth: model.width
            modelDepth: model.depth
            modelElevation: (model.elevation || 0) // some furnitures don't have the elevation property
            modelEulerRotation: Sh3dHomeModel.getEulerAnglesFromRotationMatrix(model.modelRotation.split(' '));
            levelElevation: levelModel.getElevationForId(model.level)
        }
    }

    // ----- Furniture (Doors/Windows) ------------------------------------------------
    Repeater3D {
        model: doorModel
        delegateModelAccess: DelegateModel.ReadOnly
        delegate: FurnitureDelegate {
            furnitureSource: "sh3d:/"+model.modelFile
            modelId: model.id

            materialModel: MaterialModel {
                queryId: model.id
                parentTag: "doorOrWindow"

                Component.onCompleted: loadElementsFromDocumentWithQuery()
            }

            modelAngle: model.angle
            modelPitch: model.pitch
            modelRoll: model.roll
            modelX: model.x
            modelY: model.y
            modelHeight: model.height
            modelWidth: model.width
            modelDepth: model.depth
            modelElevation: (model.elevation || 0) // some furnitures don't have the elevation property
            modelEulerRotation: Sh3dHomeModel.getEulerAnglesFromRotationMatrix(model.modelRotation.split(' '));
            levelElevation: levelModel.getElevationForId(model.level)

            Component.onCompleted: {
                let cutOutShape = model.cutOutShape;
                if (cutOutShape.startsWith("<")) {
                    console.warn("Unhandled cutOutShape for model "+model.name+": "+cutOutShape);
                    cutOutShape = "M0,0 v1 h1 v-1 z";
                }
                if (model.cutOutShape === "" && model.wallCutOutOnBothSides === "true") {
                    cutOutShape = "M0,0 v1 h1 v-1 z";
                }
                DoorAndWindowsManager.addDoorOrWindowCutOut(cutOutShape, sceneTransform, JSCad, ParseSVG);
                if (DoorAndWindowsManager.getListCutOutDoorOrWindow().length === doorModel.count) wallRepeater3D.areCutOutDoorOrWindowsReady = true;
            }
        }
    }

    // ----- Lights ---------------------------------------------------
    Repeater3D {
        model: lightModel
        delegateModelAccess: DelegateModel.ReadOnly
        delegate: LightDelegate {
                property url undefined_url
                furnitureSource: model.catalogId==='eTeks#halogenLightSource' ? undefined_url : ("sh3d:/"+model.modelFile)
                modelId: model.id

                materialModel: MaterialModel {
                    queryId: model.id
                    parentTag: "light"

                    Component.onCompleted: loadElementsFromDocumentWithQuery()
                }

                modelAngle: model.angle
                modelPitch: model.pitch
                modelRoll: model.roll
                modelX: model.x
                modelY: model.y
                modelHeight: model.height
                modelWidth: model.width
                modelDepth: model.depth
                modelElevation: (model.elevation || 0) // some furnitures don't have the elevation property
                modelEulerRotation: Sh3dHomeModel.getEulerAnglesFromRotationMatrix(model.modelRotation.split(' '));
                levelElevation: levelModel.getElevationForId(model.level)

                lightPower: model.power
                lightSourceModel: LightSourceModel {
                    queryLightId: model.id

                    Component.onCompleted: loadElementsFromDocumentWithQuery()
                }

                useOnlyDirectionalLight: root.useOnlyDirectionalLight
            }
    }
}

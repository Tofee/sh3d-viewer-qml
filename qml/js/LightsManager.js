.pragma library

var listExistingLights = [];
var minimumLightDistance = 150; // 150cm between two consecutive lights

function addNewLight(newLightPosition) {
    let tooNearALight = false;
    let alreadyThere = false;
    for (let i = 0; i < listExistingLights.length; i++) {
        let vectorToExistingLight = newLightPosition.minus(listExistingLights[i])
        if (newLightPosition.fuzzyEquals(listExistingLights[i])) {
            alreadyThere = true;
            break;
        }

        let distanceToExistingLight = Math.sqrt(vectorToExistingLight.dotProduct(vectorToExistingLight));
        if (distanceToExistingLight < minimumLightDistance) {
            tooNearALight = true;
            break;
        }
    }
    if (!tooNearALight) {
        if (!alreadyThere) listExistingLights.push(newLightPosition);
    }

    return (!tooNearALight);
}

#include "Sh3dHomeModel.h"

#include <QByteArray>
#include <QFile>
#include <QDomDocument>
#include <QVariantList>
#include <QList>
#include <QRegularExpression>
#include <QVector3D>
#include <QMatrix3x3>
#include <QQuaternion>

Sh3dHomeModel::Sh3dHomeModel(QObject *parent)
    :QObject{parent}
{
}

void Sh3dHomeModel::loadHomeXmlContent(const QString &homeXmlPath)
{
    QFile xmlHomrFile(homeXmlPath);
    if (xmlHomrFile.open(QIODevice::ReadOnly)) {
        _homeXmlDoc.setContent(&xmlHomrFile);
    }
    xmlHomrFile.close();
}

void Sh3dHomeModel::loadHomeXmlContent(const QByteArray &homeXmlContent)
{
    _homeXmlDoc.setContent(homeXmlContent);
}

// Returns the child of xmlElt that matches childQuery
QList<QDomElement> _findMatchingChildren(const QDomElement &xmlElt, const QString &childQuery, const QString &skipNode) {
    QList<QDomElement> matchingChildren;

    // First, let's handle the special case of the root "home" node
    if (childQuery == "home") {
        matchingChildren.append(xmlElt);
        return matchingChildren;
    }

    QDomNodeList children = xmlElt.childNodes();

    QRegularExpression childQueryRegEx(R"((\w+)\[@(\w+)=['"]([^'"]+)['"]\])");
    QRegularExpressionMatch childQueryParams = childQueryRegEx.match(childQuery);
    QString nodeTagToMatch, nodeAttrToMatch, nodeAttrValueToMatch ;
    if (!childQueryParams.hasMatch()) {
        nodeTagToMatch = childQuery;
    } else {
        nodeTagToMatch = childQueryParams.captured(1);
        nodeAttrToMatch = childQueryParams.captured(2);
        nodeAttrValueToMatch = childQueryParams.captured(3);
    }

    if (children.length() == 0) return matchingChildren;
    for (const QDomNode &child: children) {
        QDomElement childElt = child.toElement();
        if (childElt.isNull()) continue;
        if (childElt.nodeName() == nodeTagToMatch) {
            if (!nodeAttrToMatch.isNull()) {
                if (childElt.attribute(nodeAttrToMatch) == nodeAttrValueToMatch) {
                    matchingChildren.append(childElt);
                    break;
                }
            }
            else {
                matchingChildren.append(childElt);
            }
        }
        else if(skipNode == childElt.nodeName()) {
            // skip this node and look in its children instead
            matchingChildren.append(_findMatchingChildren(childElt, childQuery, skipNode));
        }
    }
    return matchingChildren;
}

QList<QVariant> Sh3dHomeModel::runQuery(const QString &query, const QString &skipNode)
{
    QList<QVariant> results;

    // find the query in the xmlDocument
    qsizetype i=0, j=0;

    //console.log(this+" query "+query);

    QStringList queryPathElements = query.split('/');
    QList<QDomElement> toProcess; toProcess.append(_homeXmlDoc.documentElement());
    for (i=1; i<queryPathElements.length() && toProcess.length() > 0; ++i) {
        QList<QDomElement> childrenToProcess;
        for (j=0; j<toProcess.length(); ++j) {
            childrenToProcess.append(_findMatchingChildren(toProcess[j], queryPathElements[i], skipNode));
        }
        toProcess = childrenToProcess;
    }

    // add matched elements to the final list
    for (const QDomElement& elt: toProcess) {
        QMap<QString, QVariant> elementAttrMap;
        QDomNamedNodeMap eltAttributes = elt.attributes();
        for (i=0; i<eltAttributes.length(); ++i) {
            elementAttrMap[eltAttributes.item(i).nodeName()] = eltAttributes.item(i).nodeValue();
        }
        results.append(elementAttrMap);
    }

    return results;
}

QList<QString> Sh3dHomeModel::retrieveMaterialNames(const QUrl &modelPath, bool removeDuplicates)
{
    QStringList listMaterialNames;
    QFile modelFilePath(modelPath.toLocalFile());
    if (modelFilePath.open(QIODeviceBase::ReadOnly)) {
        QString modelFileContent = modelFilePath.readAll();
        modelFilePath.close();

        // OBJ: look for usemtl material_name
        static const QRegularExpression materialObjRE(R"(usemtl (.+)\n)");
        QRegularExpressionMatchIterator materialObjMatchIter = materialObjRE.globalMatch(modelFileContent);
        while (materialObjMatchIter.hasNext()) {
            QRegularExpressionMatch materialObjMatch = materialObjMatchIter.next();
            listMaterialNames.append(materialObjMatch.captured(1));
        }

        // DAE: look for <material ... name="material_name">
        static const QRegularExpression materialDaeRE(R"(<material .*name="([^"]+))");
        QRegularExpressionMatchIterator materialDaeMatchIter = materialDaeRE.globalMatch(modelFileContent);
        while (materialDaeMatchIter.hasNext()) {
            QRegularExpressionMatch materialDaeMatch = materialDaeMatchIter.next();
            listMaterialNames.append(materialDaeMatch.captured(1));
        }
    }

    if (removeDuplicates) listMaterialNames.removeDuplicates();

    return listMaterialNames;
}

QVector3D Sh3dHomeModel::getEulerAnglesFromRotationMatrix(const QList<float> &iRotationMatrixCoefs)
{
    QMatrix3x3 rotationMatrix(iRotationMatrixCoefs.constData());
    QQuaternion::EulerAngles<float> eulerAngles = QQuaternion::fromRotationMatrix(rotationMatrix).normalized().eulerAngles();

    return QVector3D(eulerAngles.pitch, eulerAngles.yaw, eulerAngles.roll);
}

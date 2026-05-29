// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only
// Qt-Security score:significant reason:default


#include "sh3druntimeloader.h"

#include <QtQuick3DAssetUtils/private/qssgscenedesc_p.h>
#include <QtQuick3DAssetUtils/private/qssgqmlutilities_p.h>
#include <QtQuick3DAssetUtils/private/qssgrtutilities_p.h>
#include <QtQuick3DAssetImport/private/qssgassetimportmanager_p.h>
#include <QtQuick3DRuntimeRender/private/qssgrenderbuffermanager_p.h>
#if QT_CONFIG(mimetype)
#include <QtCore/qmimedatabase.h>
#endif

SH3DRuntimeLoader::SH3DRuntimeLoader(QQuick3DNode *parent)
    : QQuick3DNode(parent)
{

}

QUrl SH3DRuntimeLoader::source() const
{
    return m_source;
}

void SH3DRuntimeLoader::setSource(const QUrl &newSource)
{
    if (m_source == newSource)
        return;

    const QQmlContext *context = qmlContext(this);
    auto resolvedUrl = (context ? context->resolvedUrl(newSource) : newSource);

    if (m_source == resolvedUrl)
        return;

    m_source = resolvedUrl;
    emit sourceChanged();

    if (isComponentComplete())
        loadSource();
}

void SH3DRuntimeLoader::componentComplete()
{
    QQuick3DNode::componentComplete();
    loadSource();
}

QStringList SH3DRuntimeLoader::supportedExtensions()
{
    static QStringList extensions;
    if (!extensions.isEmpty())
        return extensions;

    /// TOFE PATCH [begin]
    static const QStringList supportedExtensions = { QLatin1StringView("obj"),
                                                     QLatin1StringView("gltf"),
                                                     QLatin1StringView("glb"),
                                                     QLatin1StringView("dae"),
                                                     QLatin1StringView("3ds")};
    /// TOFE PATCH [end]

    QSSGAssetImportManager importManager;
    const auto types = importManager.getImporterPluginInfos();

    for (const auto &t : types) {
        for (const QString &extension : t.inputExtensions) {
            if (supportedExtensions.contains(extension))
                extensions << extension;
        }
    }
    return extensions;
}

#if QT_CONFIG(mimetype)
QList<QMimeType> SH3DRuntimeLoader::supportedMimeTypes()
{
    static QList<QMimeType> mimeTypes;
    if (!mimeTypes.isEmpty())
        return mimeTypes;

    const QStringList &extensions = supportedExtensions();

    QMimeDatabase db;
    for (const auto &ext : extensions) {
        // TODO: Change to db.mimeTypesForExtension(ext), once it is implemented (QTBUG-118566)
        const QString fileName = QLatin1StringView("test.") + ext;
        mimeTypes << db.mimeTypesForFileName(fileName);
    }

    return mimeTypes;
}
#endif

static void boxBoundsRecursive(const QQuick3DNode *baseNode, const QQuick3DNode *node, QQuick3DBounds3 &accBounds)
{
    if (!node)
        return;

    if (auto *model = qobject_cast<const QQuick3DModel *>(node)) {
        auto b = model->bounds();
        for (const QVector3D point : b.bounds.toQSSGBoxPoints()) {
            auto p = model->mapPositionToNode(const_cast<QQuick3DNode *>(baseNode), point);
            if (Q_UNLIKELY(accBounds.bounds.isEmpty()))
                accBounds.bounds = { p, p };
            else
                accBounds.bounds.include(p);
        }
    }
    for (auto *child : node->childItems())
        boxBoundsRecursive(baseNode, qobject_cast<const QQuick3DNode *>(child), accBounds);
}

template<typename Func>
static void applyToModels(QQuick3DObject *obj, Func &&lambda)
{
    if (!obj)
        return;
    for (auto *child : obj->childItems()) {
        if (auto *model = qobject_cast<QQuick3DModel *>(child))
            lambda(model);
        applyToModels(child, lambda);
    }
}

void SH3DRuntimeLoader::loadSource()
{
    delete m_root;
    m_root.clear();
    QSSGBufferManager::unregisterMeshData(m_assetId);

    m_status = Status::Empty;
    m_errorString = QStringLiteral("No file selected");
    if (!m_source.isValid()) {
        emit statusChanged();
        emit errorStringChanged();
        return;
    }

    /// TOFE PATCH [begin]
    /* Load custom options, to be able to disable the material deduplication */
    QJsonObject customOptions;
    QFile optionFile(":/resources/assimpimporter_options.json");
    if (optionFile.open(QIODevice::ReadOnly)) {
        QByteArray options = optionFile.readAll();
        auto optionsDocument = QJsonDocument::fromJson(options);
        customOptions = optionsDocument.object();
    }
    /// TOFE PATCH [end]

    QSSGAssetImportManager importManager;
    QSSGSceneDesc::Scene scene;
    QString error(QStringLiteral("Unknown error"));
    auto result = importManager.importFile(m_source, scene, customOptions, &error);

    /// TOFE PATCH [begin]
    /*
     * In Qt 6.11, the assimpimporter_rt.cpp code doesn't map the assimp opacity
     *             of PrincipledMaterial nodes to their counterpart in the scane.
     * So do it ourself, for the default materials we know about.
     */
    const QMap<QString, float> listDefaultOpacities = { { "amber_trans", 0.1600 },
                                                        { "smoked_glass", 0.0200 },
                                                        { "aqua_filter", 0.0200 },
                                                        { "bluetint", 0.4300 },
                                                        { "plasma", 0.2500 },
                                                        { "emerald", 0.2500 },
                                                        { "ruby", 0.2500 },
                                                        { "sapphire", 0.2500 },
                                                        { "shadow", 0.2500 },
                                                        { "flltgrey", 0.5000 },
                                                        { "glassblutint", 0.6700 },
                                                        { "meh", 0.2500 },
                                                        { "glasstransparent", 0.2500 },
                                                        { "fleshtransparent", 0.2500 } };

    for (auto &node: scene.resources) {
        if (node->runtimeType == QSSGSceneDesc::Node::RuntimeType::PrincipledMaterial) {
            // Add this material
            m_materialNames.append(QString(node->name));
            // Also, fix the opacity
            if (listDefaultOpacities.contains(node->name)) {
               QSSGSceneDesc::setProperty(*node, "opacity", &QQuick3DPrincipledMaterial::setOpacity, listDefaultOpacities[node->name]);
            }
            QSSGSceneDesc::setProperty(*node, "metalness", &QQuick3DPrincipledMaterial::setMetalness, 0.1);
            QSSGSceneDesc::setProperty(*node, "roughness", &QQuick3DPrincipledMaterial::setRoughness, 0.6);
        }
        else if (node->runtimeType == QSSGSceneDesc::Node::RuntimeType::TextureData) {
            // Add this texture
        }
    }
    /* We've registered all the materials' names, now the JS code can proceed to patch the custom textures */
    emit materialNamesChanged();
    /// TOFE PATCH [end]

    switch (result) {
    case QSSGAssetImportManager::ImportState::Success:
        m_errorString = QStringLiteral("Success!");
        m_status = Status::Success;
        break;
    case QSSGAssetImportManager::ImportState::IoError:
        m_errorString = QStringLiteral("IO Error: ") + error;
        m_status = Status::Error;
        break;
    case QSSGAssetImportManager::ImportState::Unsupported:
        m_errorString = QStringLiteral("Unsupported: ") + error;
        m_status = Status::Error;
        break;
    }

    if (m_status == Status::Success) {
        // We create a dummy root node here, as it will be the parent to the first-level nodes
        // and resources. If we use 'this' those first-level nodes/resources won't be deleted
        // when a new scene is loaded.
        m_root = new QQuick3DNode(this);
        m_imported = QSSGRuntimeUtils::createScene(*m_root, scene);
        m_assetId = scene.id;
        m_boundsDirty = true;
        m_instancingChanged = m_instancing != nullptr;
        updateModels();
        enableBakedLighting();
        // Cleanup scene before deleting.
        scene.cleanup();
    } else {
        m_source.clear();
        emit sourceChanged();
    }

    emit statusChanged();
    emit errorStringChanged();

}

void SH3DRuntimeLoader::updateModels()
{
    if (m_instancingChanged) {
        applyToModels(m_imported, [this](QQuick3DModel *model) {
            model->setInstancing(m_instancing);
            model->setInstanceRoot(m_imported);
        });
        m_instancingChanged = false;
    }
}

void SH3DRuntimeLoader::enableBakedLighting()
{
    unsigned int idx_model = 0;

    // For each model, enable backed lighting
    applyToModels(m_imported, [this, &idx_model](QQuick3DModel *model) {
        if (!model->isUsedInBakedLighting()) {
            QQuick3DBakedLightmap *newBackedLightmap = new QQuick3DBakedLightmap();
            newBackedLightmap->setEnabled(true);
            newBackedLightmap->setKey(objectName() + ":" + QString::number(idx_model));
            model->setBakedLightmap(newBackedLightmap);
            model->setUsedInBakedLighting(true);
            connect(model, &QQuick3DModel::boundsChanged, [model] {
                QQuick3DBounds3 modelBounds = model->bounds();
                QVector3D dims = modelBounds.bounds.dimensions();

                if (dims.x() * dims.y() * dims.z() <= 0) {
                    // don't bake flat or lineic models
                    model->setUsedInBakedLighting(false);
                }
            });
            idx_model++;
        }
    });
}

SH3DRuntimeLoader::Status SH3DRuntimeLoader::status() const
{
    return m_status;
}

QString SH3DRuntimeLoader::errorString() const
{
    return m_errorString;
}

QSSGRenderGraphObject *SH3DRuntimeLoader::updateSpatialNode(QSSGRenderGraphObject *node)
{
    auto *result = QQuick3DNode::updateSpatialNode(node);
    if (m_boundsDirty)
        QMetaObject::invokeMethod(this, &SH3DRuntimeLoader::boundsChanged, Qt::QueuedConnection);
    return result;
}

void SH3DRuntimeLoader::calculateBounds()
{
    if (!m_imported || !m_boundsDirty)
        return;

    m_bounds.bounds.setEmpty();
    boxBoundsRecursive(m_imported, m_imported, m_bounds);
    m_boundsDirty = false;
}

const QQuick3DBounds3 &SH3DRuntimeLoader::bounds() const
{
    if (m_boundsDirty) {
        auto *that = const_cast<SH3DRuntimeLoader *>(this);
        that->calculateBounds();
        return that->m_bounds;
    }

    return m_bounds;
}

QQuick3DInstancing *SH3DRuntimeLoader::instancing() const
{
    return m_instancing;
}

void SH3DRuntimeLoader::setInstancing(QQuick3DInstancing *newInstancing)
{
    if (m_instancing == newInstancing)
        return;

    QQuick3DObjectPrivate::attachWatcher(this, &SH3DRuntimeLoader::setInstancing,
                                         newInstancing, m_instancing);

    m_instancing = newInstancing;
    m_instancingChanged = true;
    updateModels();
    emit instancingChanged();
}

QStringList SH3DRuntimeLoader::materialNames()
{
    return m_materialNames;
}

QT_END_NAMESPACE

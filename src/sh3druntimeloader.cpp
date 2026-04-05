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

    static const QStringList supportedExtensions = { QLatin1StringView("obj"),
                                                     QLatin1StringView("gltf"),
                                                     QLatin1StringView("glb"),
                                                     QLatin1StringView("3ds")};

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

    QJsonObject customOptions;
    QFile optionFile(":/resources/assimpimporter_options.json");
    if (optionFile.open(QIODevice::ReadOnly)) {
        QByteArray options = optionFile.readAll();
        auto optionsDocument = QJsonDocument::fromJson(options);
        customOptions = optionsDocument.object();
    }

    QSSGAssetImportManager importManager;
    QSSGSceneDesc::Scene scene;
    QString error(QStringLiteral("Unknown error"));
    auto result = importManager.importFile(m_source, scene, customOptions, &error);

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

QT_END_NAMESPACE

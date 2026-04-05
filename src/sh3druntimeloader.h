// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only
// Qt-Security score:significant reason:default


#ifndef SH3DRUNTIMELOADER_H
#define SH3DRUNTIMELOADER_H

#include <QtQuick3D/private/qquick3dmodel_p.h>
#include <QtQuick3D/private/qquick3dinstancing_p.h>

#include <QtCore/qpointer.h>
#include <QtCore/qlist.h>
#include <qqmlintegration.h>
#if QT_CONFIG(mimetype)
#include <QtCore/qmimetype.h>
#endif

class SH3DRuntimeLoader : public QQuick3DNode
{
    Q_OBJECT

    QML_NAMED_ELEMENT(SH3DRuntimeLoader)

    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
    Q_PROPERTY(QQuick3DBounds3 bounds READ bounds NOTIFY boundsChanged)
    Q_PROPERTY(QQuick3DInstancing *instancing READ instancing WRITE setInstancing NOTIFY instancingChanged)
    Q_PROPERTY(QStringList supportedExtensions READ supportedExtensions CONSTANT REVISION(6, 7))
#if QT_CONFIG(mimetype)
    Q_PROPERTY(QList<QMimeType> supportedMimeTypes READ supportedMimeTypes CONSTANT REVISION(6, 7))
#endif
    Q_PROPERTY(QStringList materialNames READ materialNames NOTIFY materialNamesChanged)

public:
    explicit SH3DRuntimeLoader(QQuick3DNode *parent = nullptr);

    QUrl source() const;
    void setSource(const QUrl &newSource);
    void componentComplete() override;
    Q_REVISION(6, 7) static QStringList supportedExtensions();
#if QT_CONFIG(mimetype)
    Q_REVISION(6, 7) static QList<QMimeType> supportedMimeTypes();
#endif
    QStringList materialNames();

    enum class Status { Empty, Success, Error };
    Q_ENUM(Status)
    Status status() const;
    QString errorString() const;
    const QQuick3DBounds3 &bounds() const;

    QQuick3DInstancing *instancing() const;
    void setInstancing(QQuick3DInstancing *newInstancing);

Q_SIGNALS:
    void sourceChanged();
    void statusChanged();
    void errorStringChanged();
    void boundsChanged();
    void instancingChanged();
    void materialNamesChanged();

protected:
    QSSGRenderGraphObject *updateSpatialNode(QSSGRenderGraphObject *node) override;

private:
    void calculateBounds();
    void loadSource();
    void updateModels();

    QPointer<QQuick3DNode> m_root;
    QPointer<QQuick3DNode> m_imported;
    QString m_assetId; // Used to release runtime assets in the buffer manager.
    QUrl m_source;
    Status m_status = Status::Empty;
    QString m_errorString;
    bool m_boundsDirty = false;
    QQuick3DBounds3 m_bounds;
    QQuick3DInstancing *m_instancing = nullptr;
    bool m_instancingChanged = false;
    QStringList m_materialNames;
};

#endif // SH3DRUNTIMELOADER_H

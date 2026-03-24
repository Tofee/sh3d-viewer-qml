// Environment.h
#ifndef ENVIRONMENT_H
#define ENVIRONMENT_H

#include <QAbstractListModel>
#include <QObject>

class Environment : public QAbstractListModel {
    Q_OBJECT
public:
    explicit Environment(QObject *parent = nullptr);
    // QAbstractListModel overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return 0; }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }
    QHash<int, QByteArray> roleNames() const override { return QHash<int, QByteArray>(); }

    // Attributes from DTD
    Q_PROPERTY(QString groundColor READ groundColor WRITE setGroundColor NOTIFY groundColorChanged)
    Q_PROPERTY(bool backgroundImageVisibleOnGround3D READ backgroundImageVisibleOnGround3D WRITE setBackgroundImageVisibleOnGround3D NOTIFY backgroundImageVisibleOnGround3DChanged)
    Q_PROPERTY(QString skyColor READ skyColor WRITE setSkyColor NOTIFY skyColorChanged)
    Q_PROPERTY(QString lightColor READ lightColor WRITE setLightColor NOTIFY lightColorChanged)
    Q_PROPERTY(QString wallsAlpha READ wallsAlpha WRITE setWallsAlpha NOTIFY wallsAlphaChanged)
    Q_PROPERTY(bool allLevelsVisible READ allLevelsVisible WRITE setAllLevelsVisible NOTIFY allLevelsVisibleChanged)
    Q_PROPERTY(bool observerCameraElevationAdjusted READ observerCameraElevationAdjusted WRITE setObserverCameraElevationAdjusted NOTIFY observerCameraElevationAdjustedChanged)
    Q_PROPERTY(QString ceillingLightColor READ ceillingLightColor WRITE setCeillingLightColor NOTIFY ceillingLightColorChanged)
    Q_PROPERTY(QString drawingMode READ drawingMode WRITE setDrawingMode NOTIFY drawingModeChanged)
    Q_PROPERTY(QString subpartSizeUnderLight READ subpartSizeUnderLight WRITE setSubpartSizeUnderLight NOTIFY subpartSizeUnderLightChanged)
    Q_PROPERTY(int photoWidth READ photoWidth WRITE setPhotoWidth NOTIFY photoWidthChanged)
    Q_PROPERTY(int photoHeight READ photoHeight WRITE setPhotoHeight NOTIFY photoHeightChanged)
    Q_PROPERTY(QString photoAspectRatio READ photoAspectRatio WRITE setPhotoAspectRatio NOTIFY photoAspectRatioChanged)
    Q_PROPERTY(int photoQuality READ photoQuality WRITE setPhotoQuality NOTIFY photoQualityChanged)
    Q_PROPERTY(int videoWidth READ videoWidth WRITE setVideoWidth NOTIFY videoWidthChanged)
    Q_PROPERTY(QString videoAspectRatio READ videoAspectRatio WRITE setVideoAspectRatio NOTIFY videoAspectRatioChanged)
    Q_PROPERTY(int videoQuality READ videoQuality WRITE setVideoQuality NOTIFY videoQualityChanged)
    Q_PROPERTY(QString videoSpeed READ videoSpeed WRITE setVideoSpeed NOTIFY videoSpeedChanged)
    Q_PROPERTY(int videoFrameRate READ videoFrameRate WRITE setVideoFrameRate NOTIFY videoFrameRateChanged)

    // Getters/Setters (inline for brevity)
    QString groundColor() const { return m_groundColor; }
    void setGroundColor(const QString &v) { if (m_groundColor != v) { m_groundColor = v; emit groundColorChanged(); } }
    bool backgroundImageVisibleOnGround3D() const { return m_backgroundImageVisibleOnGround3D; }
    void setBackgroundImageVisibleOnGround3D(bool v) { if (m_backgroundImageVisibleOnGround3D != v) { m_backgroundImageVisibleOnGround3D = v; emit backgroundImageVisibleOnGround3DChanged(); } }
    QString skyColor() const { return m_skyColor; }
    void setSkyColor(const QString &v) { if (m_skyColor != v) { m_skyColor = v; emit skyColorChanged(); } }
    QString lightColor() const { return m_lightColor; }
    void setLightColor(const QString &v) { if (m_lightColor != v) { m_lightColor = v; emit lightColorChanged(); } }
    QString wallsAlpha() const { return m_wallsAlpha; }
    void setWallsAlpha(const QString &v) { if (m_wallsAlpha != v) { m_wallsAlpha = v; emit wallsAlphaChanged(); } }
    bool allLevelsVisible() const { return m_allLevelsVisible; }
    void setAllLevelsVisible(bool v) { if (m_allLevelsVisible != v) { m_allLevelsVisible = v; emit allLevelsVisibleChanged(); } }
    bool observerCameraElevationAdjusted() const { return m_observerCameraElevationAdjusted; }
    void setObserverCameraElevationAdjusted(bool v) { if (m_observerCameraElevationAdjusted != v) { m_observerCameraElevationAdjusted = v; emit observerCameraElevationAdjustedChanged(); } }
    QString ceillingLightColor() const { return m_ceillingLightColor; }
    void setCeillingLightColor(const QString &v) { if (m_ceillingLightColor != v) { m_ceillingLightColor = v; emit ceillingLightColorChanged(); } }
    QString drawingMode() const { return m_drawingMode; }
    void setDrawingMode(const QString &v) { if (m_drawingMode != v) { m_drawingMode = v; emit drawingModeChanged(); } }
    QString subpartSizeUnderLight() const { return m_subpartSizeUnderLight; }
    void setSubpartSizeUnderLight(const QString &v) { if (m_subpartSizeUnderLight != v) { m_subpartSizeUnderLight = v; emit subpartSizeUnderLightChanged(); } }
    int photoWidth() const { return m_photoWidth; }
    void setPhotoWidth(int v) { if (m_photoWidth != v) { m_photoWidth = v; emit photoWidthChanged(); } }
    int photoHeight() const { return m_photoHeight; }
    void setPhotoHeight(int v) { if (m_photoHeight != v) { m_photoHeight = v; emit photoHeightChanged(); } }
    QString photoAspectRatio() const { return m_photoAspectRatio; }
    void setPhotoAspectRatio(const QString &v) { if (m_photoAspectRatio != v) { m_photoAspectRatio = v; emit photoAspectRatioChanged(); } }
    int photoQuality() const { return m_photoQuality; }
    void setPhotoQuality(int v) { if (m_photoQuality != v) { m_photoQuality = v; emit photoQualityChanged(); } }
    int videoWidth() const { return m_videoWidth; }
    void setVideoWidth(int v) { if (m_videoWidth != v) { m_videoWidth = v; emit videoWidthChanged(); } }
    QString videoAspectRatio() const { return m_videoAspectRatio; }
    void setVideoAspectRatio(const QString &v) { if (m_videoAspectRatio != v) { m_videoAspectRatio = v; emit videoAspectRatioChanged(); } }
    int videoQuality() const { return m_videoQuality; }
    void setVideoQuality(int v) { if (m_videoQuality != v) { m_videoQuality = v; emit videoQualityChanged(); } }
    QString videoSpeed() const { return m_videoSpeed; }
    void setVideoSpeed(const QString &v) { if (m_videoSpeed != v) { m_videoSpeed = v; emit videoSpeedChanged(); } }
    int videoFrameRate() const { return m_videoFrameRate; }
    void setVideoFrameRate(int v) { if (m_videoFrameRate != v) { m_videoFrameRate = v; emit videoFrameRateChanged(); } }

signals:
    void groundColorChanged();
    void backgroundImageVisibleOnGround3DChanged();
    void skyColorChanged();
    void lightColorChanged();
    void wallsAlphaChanged();
    void allLevelsVisibleChanged();
    void observerCameraElevationAdjustedChanged();
    void ceillingLightColorChanged();
    void drawingModeChanged();
    void subpartSizeUnderLightChanged();
    void photoWidthChanged();
    void photoHeightChanged();
    void photoAspectRatioChanged();
    void photoQualityChanged();
    void videoWidthChanged();
    void videoAspectRatioChanged();
    void videoQualityChanged();
    void videoSpeedChanged();
    void videoFrameRateChanged();

private:
    QString m_groundColor;
    bool m_backgroundImageVisibleOnGround3D = false;
    QString m_skyColor;
    QString m_lightColor;
    QString m_wallsAlpha = "0";
    bool m_allLevelsVisible = false;
    bool m_observerCameraElevationAdjusted = true;
    QString m_ceillingLightColor;
    QString m_drawingMode = "FILL";
    QString m_subpartSizeUnderLight = "0";
    int m_photoWidth = 400;
    int m_photoHeight = 300;
    QString m_photoAspectRatio = "VIEW_3D_RATIO";
    int m_photoQuality = 0;
    int m_videoWidth = 320;
    QString m_videoAspectRatio = "RATIO_4_3";
    int m_videoQuality = 0;
    QString m_videoSpeed;
    int m_videoFrameRate = 25;
};

#endif // ENVIRONMENT_H

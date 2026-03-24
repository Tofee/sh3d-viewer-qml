// BackgroundImage.h
#ifndef BACKGROUNDIMAGE_H
#define BACKGROUNDIMAGE_H

#include <QAbstractListModel>
#include <QObject>

class BackgroundImage : public QAbstractListModel {
    Q_OBJECT
public:
    explicit BackgroundImage(QObject *parent = nullptr);
    // QAbstractListModel overrides (minimal)
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return 0; }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }
    QHash<int, QByteArray> roleNames() const override { return QHash<int, QByteArray>(); }

    // Attributes from DTD
    Q_PROPERTY(QString image READ image WRITE setImage NOTIFY imageChanged)
    Q_PROPERTY(QString scaleDistance READ scaleDistance WRITE setScaleDistance NOTIFY scaleDistanceChanged)
    Q_PROPERTY(QString scaleDistanceXStart READ scaleDistanceXStart WRITE setScaleDistanceXStart NOTIFY scaleDistanceXStartChanged)
    Q_PROPERTY(QString scaleDistanceYStart READ scaleDistanceYStart WRITE setScaleDistanceYStart NOTIFY scaleDistanceYStartChanged)
    Q_PROPERTY(QString scaleDistanceXEnd READ scaleDistanceXEnd WRITE setScaleDistanceXEnd NOTIFY scaleDistanceXEndChanged)
    Q_PROPERTY(QString scaleDistanceYEnd READ scaleDistanceYEnd WRITE setScaleDistanceYEnd NOTIFY scaleDistanceYEndChanged)
    Q_PROPERTY(QString xOrigin READ xOrigin WRITE setXOrigin NOTIFY xOriginChanged)
    Q_PROPERTY(QString yOrigin READ yOrigin WRITE setYOrigin NOTIFY yOriginChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)

    // Getters/Setters
    QString image() const { return m_image; }
    void setImage(const QString &v) { if (m_image != v) { m_image = v; emit imageChanged(); } }
    QString scaleDistance() const { return m_scaleDistance; }
    void setScaleDistance(const QString &v) { if (m_scaleDistance != v) { m_scaleDistance = v; emit scaleDistanceChanged(); } }
    QString scaleDistanceXStart() const { return m_scaleDistanceXStart; }
    void setScaleDistanceXStart(const QString &v) { if (m_scaleDistanceXStart != v) { m_scaleDistanceXStart = v; emit scaleDistanceXStartChanged(); } }
    QString scaleDistanceYStart() const { return m_scaleDistanceYStart; }
    void setScaleDistanceYStart(const QString &v) { if (m_scaleDistanceYStart != v) { m_scaleDistanceYStart = v; emit scaleDistanceYStartChanged(); } }
    QString scaleDistanceXEnd() const { return m_scaleDistanceXEnd; }
    void setScaleDistanceXEnd(const QString &v) { if (m_scaleDistanceXEnd != v) { m_scaleDistanceXEnd = v; emit scaleDistanceXEndChanged(); } }
    QString scaleDistanceYEnd() const { return m_scaleDistanceYEnd; }
    void setScaleDistanceYEnd(const QString &v) { if (m_scaleDistanceYEnd != v) { m_scaleDistanceYEnd = v; emit scaleDistanceYEndChanged(); } }
    QString xOrigin() const { return m_xOrigin; }
    void setXOrigin(const QString &v) { if (m_xOrigin != v) { m_xOrigin = v; emit xOriginChanged(); } }
    QString yOrigin() const { return m_yOrigin; }
    void setYOrigin(const QString &v) { if (m_yOrigin != v) { m_yOrigin = v; emit yOriginChanged(); } }
    bool visible() const { return m_visible; }
    void setVisible(bool v) { if (m_visible != v) { m_visible = v; emit visibleChanged(); } }

signals:
    void imageChanged();
    void scaleDistanceChanged();
    void scaleDistanceXStartChanged();
    void scaleDistanceYStartChanged();
    void scaleDistanceXEndChanged();
    void scaleDistanceYEndChanged();
    void xOriginChanged();
    void yOriginChanged();
    void visibleChanged();

private:
    QString m_image;
    QString m_scaleDistance;
    QString m_scaleDistanceXStart;
    QString m_scaleDistanceYStart;
    QString m_scaleDistanceXEnd;
    QString m_scaleDistanceYEnd;
    QString m_xOrigin = "0";
    QString m_yOrigin = "0";
    bool m_visible = true;
};

#endif // BACKGROUNDIMAGE_H

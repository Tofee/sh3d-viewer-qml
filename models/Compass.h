// Compass.h
#ifndef COMPASS_H
#define COMPASS_H

#include <QAbstractListModel>
#include <QObject>

class Compass : public QAbstractListModel {
    Q_OBJECT
public:
    explicit Compass(QObject *parent = nullptr);
    // Model overrides (minimal)
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return 0; }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }
    QHash<int, QByteArray> roleNames() const override { return QHash<int, QByteArray>(); }

    // Attributes from DTD
    Q_PROPERTY(QString x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(QString y READ y WRITE setY NOTIFY yChanged)
    Q_PROPERTY(QString diameter READ diameter WRITE setDiameter NOTIFY diameterChanged)
    Q_PROPERTY(QString northDirection READ northDirection WRITE setNorthDirection NOTIFY northDirectionChanged)
    Q_PROPERTY(QString longitude READ longitude WRITE setLongitude NOTIFY longitudeChanged)
    Q_PROPERTY(QString latitude READ latitude WRITE setLatitude NOTIFY latitudeChanged)
    Q_PROPERTY(QString timeZone READ timeZone WRITE setTimeZone NOTIFY timeZoneChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)

    // Getters/Setters
    QString x() const { return m_x; }
    void setX(const QString &v) { if (m_x != v) { m_x = v; emit xChanged(); } }
    QString y() const { return m_y; }
    void setY(const QString &v) { if (m_y != v) { m_y = v; emit yChanged(); } }
    QString diameter() const { return m_diameter; }
    void setDiameter(const QString &v) { if (m_diameter != v) { m_diameter = v; emit diameterChanged(); } }
    QString northDirection() const { return m_northDirection; }
    void setNorthDirection(const QString &v) { if (m_northDirection != v) { m_northDirection = v; emit northDirectionChanged(); } }
    QString longitude() const { return m_longitude; }
    void setLongitude(const QString &v) { if (m_longitude != v) { m_longitude = v; emit longitudeChanged(); } }
    QString latitude() const { return m_latitude; }
    void setLatitude(const QString &v) { if (m_latitude != v) { m_latitude = v; emit latitudeChanged(); } }
    QString timeZone() const { return m_timeZone; }
    void setTimeZone(const QString &v) { if (m_timeZone != v) { m_timeZone = v; emit timeZoneChanged(); } }
    bool visible() const { return m_visible; }
    void setVisible(bool v) { if (m_visible != v) { m_visible = v; emit visibleChanged(); } }

signals:
    void xChanged();
    void yChanged();
    void diameterChanged();
    void northDirectionChanged();
    void longitudeChanged();
    void latitudeChanged();
    void timeZoneChanged();
    void visibleChanged();

private:
    QString m_x;
    QString m_y;
    QString m_diameter;
    QString m_northDirection = "0";
    QString m_longitude;
    QString m_latitude;
    QString m_timeZone;
    bool m_visible = true;
};

#endif // COMPASS_H

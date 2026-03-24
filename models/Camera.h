// Camera.h
#ifndef CAMERA_H
#define CAMERA_H

#include <QAbstractListModel>
#include <QObject>

class Camera : public QAbstractListModel {
    Q_OBJECT
public:
    explicit Camera(QObject *parent = nullptr);
    // Minimal model overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return 0; }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }
    QHash<int, QByteArray> roleNames() const override { return QHash<int, QByteArray>(); }

    // Common camera attributes (from %cameraCommonAttributes%)
    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString lens READ lens WRITE setLens NOTIFY lensChanged)
    Q_PROPERTY(QString x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(QString y READ y WRITE setY NOTIFY yChanged)
    Q_PROPERTY(QString z READ z WRITE setZ NOTIFY zChanged)
    Q_PROPERTY(QString yaw READ yaw WRITE setYaw NOTIFY yawChanged)
    Q_PROPERTY(QString pitch READ pitch WRITE setPitch NOTIFY pitchChanged)
    Q_PROPERTY(QString time READ time WRITE setTime NOTIFY timeChanged)
    Q_PROPERTY(QString fieldOfView READ fieldOfView WRITE setFieldOfView NOTIFY fieldOfViewChanged)
    Q_PROPERTY(QString renderer READ renderer WRITE setRenderer NOTIFY rendererChanged)
    Q_PROPERTY(QString attribute READ attribute WRITE setAttribute NOTIFY attributeChanged)

    // Getters/Setters
    QString id() const { return m_id; }
    void setId(const QString &v) { if (m_id != v) { m_id = v; emit idChanged(); } }
    QString name() const { return m_name; }
    void setName(const QString &v) { if (m_name != v) { m_name = v; emit nameChanged(); } }
    QString lens() const { return m_lens; }
    void setLens(const QString &v) { if (m_lens != v) { m_lens = v; emit lensChanged(); } }
    QString x() const { return m_x; }
    void setX(const QString &v) { if (m_x != v) { m_x = v; emit xChanged(); } }
    QString y() const { return m_y; }
    void setY(const QString &v) { if (m_y != v) { m_y = v; emit yChanged(); } }
    QString z() const { return m_z; }
    void setZ(const QString &v) { if (m_z != v) { m_z = v; emit zChanged(); } }
    QString yaw() const { return m_yaw; }
    void setYaw(const QString &v) { if (m_yaw != v) { m_yaw = v; emit yawChanged(); } }
    QString pitch() const { return m_pitch; }
    void setPitch(const QString &v) { if (m_pitch != v) { m_pitch = v; emit pitchChanged(); } }
    QString time() const { return m_time; }
    void setTime(const QString &v) { if (m_time != v) { m_time = v; emit timeChanged(); } }
    QString fieldOfView() const { return m_fieldOfView; }
    void setFieldOfView(const QString &v) { if (m_fieldOfView != v) { m_fieldOfView = v; emit fieldOfViewChanged(); } }
    QString renderer() const { return m_renderer; }
    void setRenderer(const QString &v) { if (m_renderer != v) { m_renderer = v; emit rendererChanged(); } }
    QString attribute() const { return m_attribute; }
    void setAttribute(const QString &v) { if (m_attribute != v) { m_attribute = v; emit attributeChanged(); } }

signals:
    void idChanged();
    void nameChanged();
    void lensChanged();
    void xChanged();
    void yChanged();
    void zChanged();
    void yawChanged();
    void pitchChanged();
    void timeChanged();
    void fieldOfViewChanged();
    void rendererChanged();
    void attributeChanged();

private:
    QString m_id;
    QString m_name;
    QString m_lens = "PINHOLE";
    QString m_x;
    QString m_y;
    QString m_z;
    QString m_yaw;
    QString m_pitch;
    QString m_time;
    QString m_fieldOfView;
    QString m_renderer;
    QString m_attribute; // required attribute (topCamera|storedCamera|cameraPath)
};

#endif // CAMERA_H

// Home.h
#ifndef HOME_H
#define HOME_H

#include <QAbstractListModel>
#include <QObject>

class Home : public QAbstractListModel {
    Q_OBJECT
public:
    explicit Home(QObject *parent = nullptr);
    // Required overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Attributes from DTD
    Q_PROPERTY(QString version READ version WRITE setVersion NOTIFY versionChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString camera READ camera WRITE setCamera NOTIFY cameraChanged)
    Q_PROPERTY(QString selectedLevel READ selectedLevel WRITE setSelectedLevel NOTIFY selectedLevelChanged)
    Q_PROPERTY(QString wallHeight READ wallHeight WRITE setWallHeight NOTIFY wallHeightChanged)
    Q_PROPERTY(bool basePlanLocked READ basePlanLocked WRITE setBasePlanLocked NOTIFY basePlanLockedChanged)
    Q_PROPERTY(QString furnitureSortedProperty READ furnitureSortedProperty WRITE setFurnitureSortedProperty NOTIFY furnitureSortedPropertyChanged)
    Q_PROPERTY(bool furnitureDescendingSorted READ furnitureDescendingSorted WRITE setFurnitureDescendingSorted NOTIFY furnitureDescendingSortedChanged);

    // Getters/Setters
    QString version() const; void setVersion(const QString &v);
    QString name() const; void setName(const QString &n);
    QString camera() const; void setCamera(const QString &c);
    QString selectedLevel() const; void setSelectedLevel(const QString &s);
    QString wallHeight() const; void setWallHeight(const QString &w);
    bool basePlanLocked() const; void setBasePlanLocked(bool b);
    QString furnitureSortedProperty() const; void setFurnitureSortedProperty(const QString &p);
    bool furnitureDescendingSorted() const; void setFurnitureDescendingSorted(bool b);

signals:
    void versionChanged();
    void nameChanged();
    void cameraChanged();
    void selectedLevelChanged();
    void wallHeightChanged();
    void basePlanLockedChanged();
    void furnitureSortedPropertyChanged();
    void furnitureDescendingSortedChanged();

private:
    // Store attributes
    QString m_version;
    QString m_name;
    QString m_camera;
    QString m_selectedLevel;
    QString m_wallHeight;
    bool m_basePlanLocked = false;
    QString m_furnitureSortedProperty;
    bool m_furnitureDescendingSorted = false;
};

#endif // HOME_H

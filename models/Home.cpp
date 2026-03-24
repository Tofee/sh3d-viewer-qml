// Home.cpp
#include "Home.h"

Home::Home(QObject *parent)
    : QAbstractListModel(parent)
{
    // Initialize default values if needed
}

int Home::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    // This model could represent child elements like properties, etc.
    return 0;
}

QVariant Home::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(index);
    Q_UNUSED(role);
    return QVariant();
}

QHash<int, QByteArray> Home::roleNames() const
{
    return QHash<int, QByteArray>();
}

// Getters/Setters implementations
QString Home::version() const { return m_version; }
void Home::setVersion(const QString &v) { if (m_version != v) { m_version = v; emit versionChanged(); } }
QString Home::name() const { return m_name; }
void Home::setName(const QString &v) { if (m_name != v) { m_name = v; emit nameChanged(); } }
QString Home::camera() const { return m_camera; }
void Home::setCamera(const QString &v) { if (m_camera != v) { m_camera = v; emit cameraChanged(); } }
QString Home::selectedLevel() const { return m_selectedLevel; }
void Home::setSelectedLevel(const QString &v) { if (m_selectedLevel != v) { m_selectedLevel = v; emit selectedLevelChanged(); } }
QString Home::wallHeight() const { return m_wallHeight; }
void Home::setWallHeight(const QString &v) { if (m_wallHeight != v) { m_wallHeight = v; emit wallHeightChanged(); } }
bool Home::basePlanLocked() const { return m_basePlanLocked; }
void Home::setBasePlanLocked(bool v) { if (m_basePlanLocked != v) { m_basePlanLocked = v; emit basePlanLockedChanged(); } }
QString Home::furnitureSortedProperty() const { return m_furnitureSortedProperty; }
void Home::setFurnitureSortedProperty(const QString &v) { if (m_furnitureSortedProperty != v) { m_furnitureSortedProperty = v; emit furnitureSortedPropertyChanged(); } }
bool Home::furnitureDescendingSorted() const { return m_furnitureDescendingSorted; }
void Home::setFurnitureDescendingSorted(bool v) { if (m_furnitureDescendingSorted != v) { m_furnitureDescendingSorted = v; emit furnitureDescendingSortedChanged(); } }

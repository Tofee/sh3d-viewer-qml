// FurnitureVisibleProperty.h
#ifndef FURNITUREVISIBLEPROPERTY_H
#define FURNITUREVISIBLEPROPERTY_H

#include <QAbstractListModel>
#include <QObject>

class FurnitureVisibleProperty : public QAbstractListModel {
    Q_OBJECT
public:
    explicit FurnitureVisibleProperty(QObject *parent = nullptr);
    // Minimal model overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return 0; }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }
    QHash<int, QByteArray> roleNames() const override { return QHash<int, QByteArray>(); }

    // Attributes
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

    QString name() const { return m_name; }
    void setName(const QString &n) { if (m_name != n) { m_name = n; emit nameChanged(); } }

signals:
    void nameChanged();

private:
    QString m_name;
};

#endif // FURNITUREVISIBLEPROPERTY_H

// Property.h
#ifndef PROPERTY_H
#define PROPERTY_H

#include <QAbstractListModel>
#include <QObject>

class Property : public QAbstractListModel {
    Q_OBJECT
public:
    explicit Property(QObject *parent = nullptr);
    // QAbstractListModel overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return 0; }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }
    QHash<int, QByteArray> roleNames() const override { return QHash<int, QByteArray>(); }

    // Attributes
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString value READ value WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)

    QString name() const { return m_name; }
    void setName(const QString &n) { if (m_name != n) { m_name = n; emit nameChanged(); } }
    QString value() const { return m_value; }
    void setValue(const QString &v) { if (m_value != v) { m_value = v; emit valueChanged(); } }
    QString type() const { return m_type; }
    void setType(const QString &t) { if (m_type != t) { m_type = t; emit typeChanged(); } }

signals:
    void nameChanged();
    void valueChanged();
    void typeChanged();

private:
    QString m_name;
    QString m_value;
    QString m_type = "STRING"; // default per DTD
};

#endif // PROPERTY_H

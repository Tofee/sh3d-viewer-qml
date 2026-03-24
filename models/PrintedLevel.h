// PrintedLevel.h
#ifndef PRINTEDLEVEL_H
#define PRINTEDLEVEL_H

#include <QAbstractListModel>
#include <QObject>

class PrintedLevel : public QAbstractListModel {
    Q_OBJECT
public:
    explicit PrintedLevel(QObject *parent = nullptr);
    // Minimal overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return 0; }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }
    QHash<int, QByteArray> roleNames() const override { return QHash<int, QByteArray>(); }

    // Attribute: level ID reference
    Q_PROPERTY(QString level READ level WRITE setLevel NOTIFY levelChanged)

    QString level() const { return m_level; }
    void setLevel(const QString &v) { if (m_level != v) { m_level = v; emit levelChanged(); } }

signals:
    void levelChanged();

private:
    QString m_level; // ID reference
};

#endif // PRINTEDLEVEL_H

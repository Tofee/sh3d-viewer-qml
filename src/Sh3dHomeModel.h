#ifndef SH3DHOMEMODEL_H
#define SH3DHOMEMODEL_H

#include <QObject>
#include <QDomDocument>
#include <QQmlEngine>
#include <QVariantList>

class QByteArray;

class Sh3dHomeModel : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    explicit Sh3dHomeModel(QObject *parent = nullptr);

    void loadHomeXmlContent(const QByteArray &homeXmlContent);

    Q_INVOKABLE QList<QVariant> runQuery(const QString &query, const QString &skipNode);

signals:

private:
    QDomDocument _homeXmlDoc;
};

#endif // SH3DHOMEMODEL_H

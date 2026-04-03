#ifndef SH3DHOMEMODEL_H
#define SH3DHOMEMODEL_H

#include <QObject>
#include <QDomDocument>
#include <QQmlEngine>
#include <QVariantList>
#include <QVector3D>
#include <QList>

class QByteArray;

class Sh3dHomeModel : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    explicit Sh3dHomeModel(QObject *parent = nullptr);

    void loadHomeXmlContent(const QString &homeXmlPath);
    void loadHomeXmlContent(const QByteArray &homeXmlContent);

    Q_INVOKABLE QList<QVariant> runQuery(const QString &query, const QString &skipNode);
    Q_INVOKABLE QList<QString> retrieveMaterialNames(const QUrl &modelPath, bool removeDuplicates = true);
    Q_INVOKABLE QVector3D getEulerAnglesFromRotationMatrix(const QList<float> &iRotationMatrixCoefs);

signals:

private:
    QDomDocument _homeXmlDoc;
};

#endif // SH3DHOMEMODEL_H

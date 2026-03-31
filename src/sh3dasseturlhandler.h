#ifndef SH3DASSETURLHANDLER_H
#define SH3DASSETURLHANDLER_H

#include <QQmlAbstractUrlInterceptor>
#include <QString>
#include <QDir>

class SH3DAssetUrlHandler : public QQmlAbstractUrlInterceptor
{
public:
    SH3DAssetUrlHandler() {
        QDir::setSearchPaths(assetScheme,{":/sh3d"});
    }

    virtual QUrl intercept(const QUrl& path, QQmlAbstractUrlInterceptor::DataType type) override;

private:
    const QString assetScheme = "sh3d";
};

#endif // SH3DASSETURLHANDLER_H

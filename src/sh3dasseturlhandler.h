#ifndef SH3DASSETURLHANDLER_H
#define SH3DASSETURLHANDLER_H

#include <QQmlAbstractUrlInterceptor>
#include <QString>

class SH3DAssetUrlHandler : public QQmlAbstractUrlInterceptor
{
public:
    SH3DAssetUrlHandler() {
//        QDir::setSearchPaths("sh3d",{":/sh3d", QGuiApplication::applicationDirPath() + "/sh3d"});
        /*
         * POC: return sh3d resource data directly as Qt resources
         *  - load zip in memory (use QMicroZip)
QByteArray first_file_from_zip;       // will store the decompressed data of the first file
QFile file("zip_file_path");          // path to existing zip file

if (file.open(QFile::ReadOnly)) {
    QByteArray ba = file.readAll();   // reading the zip file into memory

    if (QMicros::isArchive(ba)) {     // checking whether the byte array is an archive
        QMicroz qmz(ba);              // setting the buffered zip

        first_file_from_zip = qmz.extractData(0);
        QString first_file_from_zip_path = qmz.name(0); name/path of the first file in zip
    }
}

         *  - for each file buffer, add a dedicated QResource with corresponding prefix path
         *    bool QResource::registerResource(first_file_from_zip.buffer(), first_file_from_zip_path)
         *  - catch (all?) URLs for models/textures, and use "sh3d:relative_path" instead
         */
    }

    virtual QUrl intercept(const QUrl& path, QQmlAbstractUrlInterceptor::DataType type) override;

private:
    const QString assetScheme = "sh3d";
};

#endif // SH3DASSETURLHANDLER_H

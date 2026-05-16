#include "sh3dasseturlhandler.h"

#include <QUrl>
#include <QFileInfo>

QUrl SH3DAssetUrlHandler::intercept(const QUrl& path, QQmlAbstractUrlInterceptor::DataType type)
{
    if (type == QQmlAbstractUrlInterceptor::DataType::QmldirFile)
        return path; // no need to lookup these files; this is about assets, not about QML files

    auto scheme = path.scheme();
    if (scheme == assetScheme) {
        QFileInfo fi("sh3d:" + path.toString().mid(5));
        if (!fi.exists() && fi.suffix().isNull()) {
            for (const QString &modelExt: { ".obj", ".dae" }) {
                QString filePathWithExt = fi.filePath() + modelExt;
                if (QFileInfo().exists(filePathWithExt)) return QUrl::fromLocalFile(filePathWithExt);
            }
        }
        if (fi.exists()) {
#if 0
            // not useful here, as our dirSearchPath doesn't contain a resource target
            if (fi.filePath().startsWith(":/")) {
                // we need to deal with files in the resources by adding the url scheme for them
                return QUrl("qrc" + fi.filePath());
            }
#endif
            return QUrl::fromLocalFile(fi.filePath());
        }
        else {
            printf("Couldn't find %s !\n", fi.filePath().toLatin1().data());
        }
    }
    return path;
}

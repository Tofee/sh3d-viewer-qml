#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDomDocument>
#include <QFile>
#include <QDirIterator>
#include <QString>
#include <QStringList>
#include <QTextStream>
#include <QRegularExpression>
#if 0
#include <QMap>
#include <QResource>
#include <QByteArray>
#else
#include <QTemporaryDir>
#endif
#include <QDebug>

#include "Sh3dHomeModel.h"
#include "sh3dasseturlhandler.h"
#include "qmicroz.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    if (app.arguments().length() < 2) {
        printf("ERROR: missing argument.\n");
        printf("Usage: %s <myModel.sh3d>.\n", app.arguments().at(0).toLatin1().data());
        exit(1);
    }

#if USE_QRESOURCE_ASSETS
    // This BufList will hold all the data of the sh3d zip file
    BufList sh3dDataMap;

    // Open the sh3d file in argument and extract its content to memory
    QFile sh3dFile(app.arguments().at(1));          // path to existing zip file
    if (sh3dFile.open(QFile::ReadOnly)) {
        QByteArray sh3dFileContent = sh3dFile.readAll();   // reading the zip file into memory
        if (QMicroz::isArchive(sh3dFileContent)) {     // checking whether the byte array is an archive
            QMicroz sh3dFileZip(sh3dFileContent);              // setting the buffered zip

            // Extracts all files into the RAM buffer as a QMap { "name/path" : data }
            sh3dDataMap = sh3dFileZip.extractToBuf();
        }
        sh3dFile.close();
    }

    // Now create a QResource for each of the file data
    for (auto fileData_i = sh3dDataMap.cbegin(); fileData_i != sh3dDataMap.cend(); ++fileData_i) {
        QByteArray fileData = fileData_i.value();
        QString filePath = fileData_i.key();
        if (filePath.endsWith('/')) continue;
        qDebug() << "Registering " << ("/sh3d/"+filePath) << " as a resource. Bytes: " << fileData.size();
        bool ok = QResource::registerResource(reinterpret_cast<const uchar*>(fileData_i.value().constData()), "/sh3d/"+filePath);
    }
#else
    QTemporaryDir tmpAssetsDir;
    QString tmpAssetDirPath = tmpAssetsDir.path();
    if (tmpAssetsDir.isValid()) {
        // Extract the sh3d file to temp dir
        QMicroz::extract(app.arguments().at(1), tmpAssetDirPath);
    }

    // Now post-process the extracted 3D models:
    //  - rename ./<number> model files to ./number.obj or ./number.dae depending on detected content
    //  - in .obj files, add a header line with "usemtl :/resources/default.mtl" which will hopefully become the actual default.mtl file content
    //  - process all obj and dae file to build a map { index->texture_name } for each 3D model file

    QFile::copy(":/resources/default.mtl", tmpAssetDirPath + "/default.mtl");

    // First, find all the pointed models in Home.xml
    QStringList listModelUsed;
    QFile xmlModelFile(tmpAssetDirPath + "/Home.xml");
    if (xmlModelFile.open(QIODeviceBase::ReadOnly)) {
        QString xmlModelFileContent = xmlModelFile.readAll();
        xmlModelFile.close();

        static const QRegularExpression modelAttrRE(R"( model=['"]([^'"]+))");
        QRegularExpressionMatchIterator modelAttrMatchIter = modelAttrRE.globalMatch(xmlModelFileContent);
        while (modelAttrMatchIter.hasNext()) {
            QRegularExpressionMatch modelAttrMatch = modelAttrMatchIter.next();
            listModelUsed.append(modelAttrMatch.captured(1));
        }
    }

    listModelUsed.removeDuplicates();
    for(const QString &modelFileRelPath: listModelUsed) {
        QFileInfo resFileInfo(tmpAssetDirPath + "/" + modelFileRelPath);
        if (!resFileInfo.isFile()) continue;

        QString resFileSuffix = resFileInfo.suffix();
        if (resFileSuffix.isNull()) {
            // check content, detect DAE or OBJ files
            QFile resFile(resFileInfo.absoluteFilePath());
            if (resFile.open(QIODeviceBase::ReadOnly)) {

                static QMap<QStringList, QString> magic_tokens({
                    { QStringList({ "mtllib", "usemtl ", "v ", "vt ", "vn ", "o ", "g ", "s ", "f " }), ".obj" },
                    { QStringList({ "<collada" }), ".dae" }
                });

                QTextStream resStream (&resFile);
                QString lineToSearch;
                QString foundFileType;
                do {
                    lineToSearch = resStream.readLine();
                    for (auto magic_tokenlist =  magic_tokens.cbegin(); foundFileType.isNull() && magic_tokenlist != magic_tokens.cend(); ++magic_tokenlist) {
                        for (const QString &magic_token: magic_tokenlist.key()) {
                            if (lineToSearch.contains(magic_token, Qt::CaseSensitive)) {
                                foundFileType = magic_tokenlist.value();
                                break;
                            }
                        }
                    }
                } while (foundFileType.isNull() && !lineToSearch.isNull());

                resFile.close();

                if (!foundFileType.isNull()) {
                    // rename it
                    resFile.rename(resFile.fileName() + foundFileType);
                }
                if (foundFileType == ".obj") {
                    // prepend mtllib :/resources/default.mtl at the beginning of the file
                    if (resFile.open(QIODeviceBase::ReadOnly)) {
                        QByteArray fullObjContent = resFile.readAll();
                        resFile.close();

                        if (QString(fullObjContent).contains("usemtl", Qt::CaseSensitive)) {
                            if (resFile.open(QIODeviceBase::WriteOnly /*this will empty the file*/)) {
                                resFile.write(QString("mtllib " + tmpAssetDirPath + "/default.mtl\n").toLatin1());
                                resFile.write(fullObjContent);
                                resFile.close();
                            }
                        }
                        else {
                            printf("%s Don't insert default.mtl, no need.\n", resFile.fileName().toLatin1().data());
                        }
                    }
                }
            }
        }
    }
#endif

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    SH3DAssetUrlHandler sh3dUrlHandler(tmpAssetsDir.path());
    engine.addUrlInterceptor(&sh3dUrlHandler);

    Sh3dHomeModel *homeModel = engine.singletonInstance<Sh3dHomeModel *>("sh3d_viewer_qml", "Sh3dHomeModel");
    homeModel->loadHomeXmlContent(QString("sh3d:/Home.xml"));

    engine.loadFromModule("sh3d_viewer_qml", "Main");

    return QCoreApplication::exec();
}

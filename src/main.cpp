#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDomDocument>
#include <QFile>
#include <QMap>
#include <QString>
#include <QResource>
#include <QByteArray>
#include <QDebug>

#include "Sh3dHomeModel.h"
#include "sh3dasseturlhandler.h"
#include "qmicroz.h"

int main(int argc, char *argv[])
{
    // needed to parse the SH3D xml file
    qputenv("QML_XHR_ALLOW_FILE_READ", "1");

    QGuiApplication app(argc, argv);

    if (app.arguments().length() < 2) {
        printf("ERROR: missing argument.\n");
        printf("Usage: %s <myModel.sh3d>.\n", app.arguments().at(0).toLatin1().data());
        exit(1);
    }

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


    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    Sh3dHomeModel *homeModel = engine.singletonInstance<Sh3dHomeModel *>("sh3d_viewer_qml", "Sh3dHomeModel");
    homeModel->loadHomeXmlContent(sh3dDataMap["Home.xml"]);

//    SH3DAssetUrlHandler sh3dUrlHandler;
//    engine.addUrlInterceptor(&sh3dUrlHandler);

    engine.loadFromModule("sh3d_viewer_qml", "Main");

    return QCoreApplication::exec();
}

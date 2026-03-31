#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    // needed to parse the SH3D xml file
    qputenv("QML_XHR_ALLOW_FILE_READ", "1");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.setInitialProperties({
        { "xmlSourceDir", QUrl::fromLocalFile(app.arguments().at(1)) }
    });
    engine.loadFromModule("sh3d_viewer_qml", "Main");

    return QCoreApplication::exec();
}

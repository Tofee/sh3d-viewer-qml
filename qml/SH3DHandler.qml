import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1

Item {
    id: sh3dUnpacker
    property string xmlSource: ""
    signal xmlReady(string path)

    // temporary directory (unique per run)
    property string tempDir: ""

    FileDialog {
        id: fileDialog
        title: "Open .sh3d file"
        nameFilters: ["sh3d files (*.sh3d)"]
        onAccepted: {
            var zipPath = fileDialog.fileUrl.toLocalFile()
            // create a unique temporary directory
            tempDir = Qt.resolvedUrl("tmp_" + Date.now())
            // make the directory
            mkdirProc.start("mkdir", ["-p", tempDir])
        }
    }

    Process {
        id: mkdirProc
        onFinished: {
            // after directory is created, unzip the file
            unzipProc.start("unzip", [zipPath, "-d", tempDir])
        }
        onErrorOccurred: console.log("Failed to create temp directory:", errorString)
    }

    Process {
        id: unzipProc
        property string zipPath: ""
        onStarted: {
            // capture the zip path from the FileDialog when the process starts
            zipPath = fileDialog.fileUrl.toLocalFile()
        }
        onFinished: {
            var homeFile = tempDir + "/Home.xml"
            xmlSource = "file://" + homeFile
            xmlReady(xmlSource)
        }
        onErrorOccurred: console.log("Unzip failed:", errorString)
    }

    Component.onCompleted: fileDialog.open()
}
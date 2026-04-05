import QtQuick

import "."
import sh3d_viewer_qml

Sh3dXmlModel {
    id: rootMaterialModel
    query: "/home/"+parentTag+"[@id='"+queryId+"']/material"
    property string queryId
    property string parentTag

    defaultInitValues: ({ name: '',
                          color: ''
                        })
}

// RoomModel.qml
import QtQuick
import QtQml.Models
import "."

ListModel {
    id: sh3DXmlListModel
    property string query;
    property string skipNode: "furnitureGroup";
    property variant defaultInitValues;
    signal loadModelCompleted;

    // utility used to retrieve
    property Sh3dXmlObject xmlReader

    function loadElementsFromDocumentWithQuery() {
        // find the query in the xmlDocument
        let i=0, j=0;

        //console.log(this+" query "+query);

        let queryPathElements = query.split('/');
        let toProcess = [ xmlReader.xmlDocument ];
        for (i=1; i<queryPathElements.length && toProcess.length > 0; ++i) {
            let childrenToProcess = []
            for (j=0; j<toProcess.length; ++j) {
                childrenToProcess.push(... _findMatchingChildren(toProcess[j], queryPathElements[i]))
            }
            toProcess = childrenToProcess;
        }

        // we found no match, just leave the model empty.
        for (j=0; j<toProcess.length; ++j) {
            _addFoundChildToListModel(toProcess[j]);
        }

        sh3DXmlListModel.loadModelCompleted();
    }
    // Returns the child of xmlElt that matches childQuery
    function _findMatchingChildren(xmlElt: variant, childQuery: string): variant {
        let matchingChildren = [];
        let children = (!!xmlElt.documentElement) ? [ xmlElt.documentElement ] : xmlElt.childNodes;

        let childQueryRegEx = /(\w+)\[@(\w+)=['"]([^'"]+)['"]\]/
        let childQueryParams = childQueryRegEx.exec(childQuery);
        if (!childQueryParams) childQueryParams = [childQuery, childQuery]; // simple query fallback

        for (let i=0; i<children.length; ++i) {
            let child = children[i];
            if (child.nodeName === childQueryParams[1]) {
                if (childQueryParams.length === 4) {
                    for (let i_attr=0; i_attr<child.attributes.length; ++i_attr) {
                        if (child.attributes[i_attr].name === childQueryParams[2] && child.attributes[i_attr].value === childQueryParams[3]) {
                            matchingChildren.push(child);
                            break;
                        }
                    }
                }
                else {
                    matchingChildren.push(child);
                }
            }
            else if(skipNode && skipNode === child.nodeName) {
                // skip this node and look in its children instead
                matchingChildren.push(... _findMatchingChildren(child, childQuery));
            }
        }
        return matchingChildren;
    }
    function _addFoundChildToListModel(xmlElt: variant) {
        let o = {};
        for (let defaultAttr in defaultInitValues) {
            o[defaultAttr] = defaultInitValues[defaultAttr];
        }
        for (let i=0; i<xmlElt.attributes.length; ++i) {
            if (xmlElt.attributes[i].name === "model")
                o["modelFile"] = xmlElt.attributes[i].value; // special hack to avoid conflict with ListModel
            else
                o[xmlElt.attributes[i].name] = xmlElt.attributes[i].value;
        }
        sh3DXmlListModel.append(o);
    }

    property Connections _loadedObserver: Connections {
        target: xmlReader
        function onLoadCompleted() {
            loadElementsFromDocumentWithQuery();
        }
    }

    Component.onCompleted: {
        // xml document already loaded, emit the signal to populate the list
        //if (!!xmlReader.xmlDocument) xmlReader.loadCompleted();
    }
}

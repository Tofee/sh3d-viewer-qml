// RoomModel.qml
import QtQuick
import QtQml.Models
import "."

ListModel {
    id: sh3DXmlListModel
    property string query;
    property variant defaultInitValues;
    signal loadModelCompleted;

    // utility used to retrieve
    property Sh3dXmlObject xmlReader

    function loadElementsFromDocumentWithQuery() {
        // find the query in the xmlDocument
        let foundLeaf;

        console.log(this+" query "+query);

        let queryPathElements = query.split('/');
        let currentElement = xmlReader.xmlDocument;
        for (let i=1; i<queryPathElements.length && currentElement; ++i) {
            currentElement = _findMatchingChild(currentElement, queryPathElements[i])
            if (i == queryPathElements.length-1) foundLeaf = currentElement;
        }

        // we found no match, just leave the model empty.
        if (!foundLeaf) return;

        let foundLeafNodeName = foundLeaf.nodeName;
        while (foundLeaf) {
            // for each of foundChild siblings of name type (including itself), add an element to the ListModel
            // with all the attributes' values
            if (foundLeaf.nodeName === foundLeafNodeName) {
                _addFoundChildToListModel(foundLeaf);
            }
            foundLeaf = foundLeaf.nextSibling;
        }

        sh3DXmlListModel.loadModelCompleted();
    }
    // Returns the child of xmlElt that matches childQuery
    function _findMatchingChild(xmlElt: variant, childQuery: string): variant {
        let children = (!!xmlElt.documentElement) ? [ xmlElt.documentElement ] : xmlElt.childNodes;

        let childQueryRegEx = /(\w+)\[@(\w+)=['"]([^'"]+)['"]\]/
        let childQueryParams = childQueryRegEx.exec(childQuery);
        if (!childQueryParams) childQueryParams = [childQuery, childQuery]; // simple query fallback

        for (let i=0; i<children.length; ++i) {
            let child = children[i];
            let isMaching = false;
            if (child.nodeName === childQueryParams[1]) {
                if (childQueryParams.length === 4) {
                    for (let i_attr=0; i_attr<child.attributes.length; ++i_attr) {
                        if (child.attributes[i_attr].name === childQueryParams[2] && child.attributes[i_attr].value === childQueryParams[3]) {
                            isMaching = true;
                            break;
                        }
                    }
                }
                else {
                    isMaching = true;
                }
                if (isMaching) return child;
            }
        }
        return null;
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

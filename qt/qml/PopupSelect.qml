import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup{
    id: root
    property string code :""   // client|database|acntno|(1|2|4 article)
    property var jsdata     // JSON value: id, name, fullname, scancode, mask, sect
    // width:300
    // height: root.height*0.8
    // x: (root.width-width)/2

    signal vkEvent(string id, var param)

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    ListView{
        id: vw
        anchors.fill: parent
        currentIndex: -1
        clip: true
        spacing: 0
        ScrollBar.vertical: ScrollBar{
            parent: vw.parent
            anchors.top: vw.top
            anchors.left: vw.right
            anchors.bottom: vw.bottom
        }
        model: ListModel{}
        delegate: Rectangle{
            width:vw.width
            height:childrenRect.height
            color: index%2==0 ? 'white' : 'whitesmoke'  // Qt.darker('white',0.5)
            ColumnLayout{
                spacing: 0
                Label{text:name}
                RowLayout{
                    Label{text:id; color:'gray'}
                    Label{text:fullname; color:'gray'}
                }
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    vkEvent(root.code, id)
                    // if (selectPopup.code==="client"){                  // client
                    //     stack.children[stack.currentIndex].crntClient = Lib.getClient(Db,id);
                    //     stack.children[stack.currentIndex].crntAcnt = Lib.getAccount(Db)
                    // } else if (selectPopup.code==="database") {        // database
                    //     root.dbname = id
                    //     // openConnection(id)
                    // } else if (selectPopup.code==="acntno") {        // acntno
                    //     stack.children[stack.currentIndex].crntAcnt = Lib.getAccount(Db, id)
                    //     // setAccount(id)
                    // } else if (selectPopup.code==="article") {
                    //     stack.children[stack.currentIndex].newDcm(id)
                    // } else {
                    //     Lib.log("selectPopup bad code, nothing to do","Main", "EE")
                    //     // bad code, nothing to do
                    // }
                    root.close()
                }
            }
        }
        section.property: "sect"
        section.criteria: ViewSection.FullString
        section.delegate: Rectangle{
            width: vw.width
            height: 30  //*/childrenRect.height*1.2
            color: "silver"
            Label{
                font.pixelSize: 12;
                text:'  '+section;
                anchors{verticalCenter: parent.verticalCenter}
            }
        }
        function vpopulate(vfilter) {
            model.clear()
            for (var r =0; r < root.jsdata.length; ++r){
                if (vfilter === undefined || vfilter === ''
                        || ~(root.jsdata[r].id.indexOf(vfilter))
                        || ~(root.jsdata[r].name.toLowerCase()).indexOf(String(vfilter).toLowerCase())
                        || ~(root.jsdata[r].fullname.toLowerCase()).indexOf(String(vfilter).toLowerCase())
                        || (root.jsdata[r].scancode !== undefined && ~(root.jsdata[r].scancode).indexOf(String(vfilter)))
                        ){
                    model.append(root.jsdata[r])
                }
            }
        }
    }
    TextField{
        id: filterEdit
        height: 26
        width: 80
//            font.pixelSize: 8
        anchors{right:parent.right;bottom:parent.bottom}
        selectByMouse: true
        placeholderText: 'фільтр'
//            color: text==''?'lightgray':'black'
        onAccepted: vw.vpopulate(text)
    }
    onVisibleChanged: if(!visible){filterEdit.text=''; root.code = ""} else {vw.vpopulate(filterEdit.text); filterEdit.forceActiveFocus();}

}

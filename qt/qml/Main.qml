import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import com.singleton.dbdriver4 1.0

import "../js/std.js" as Lib
import "../js/v146/sqlStatAcnts.js" as LibAcnts

ApplicationWindow {
    id: root
    width: 1080
    height: 570
    visible: true
    title: qsTr("vkStat") + String("#%1").arg("0.1")

    property string dbname: ""
    onDbnameChanged: {
        Db.setDbParameter(dbname);
        const ayears = LibAcnts.dbStrgAcntYears(Db)
        statMonth.years = ayears
        if (ayears.length > 0){
            let atmp = []
            const onlyTen = Number(ayears[ayears.length -1]) +8
            let i =0
            do {
                atmp.push(ayears[i])
                ++i
            } while (i < 10 && Number(ayears[i]) > onlyTen)
            statYear.years = atmp
        }


        statCrnt.db = Db
        statMonth.db = Db
        statYear.db = Db
    }

    function dbg(str, code ="") {
        console.log( String("[Main.qml]#%1 %2").arg(code).arg(str));
    }

    Action {
        id: changeDBAction
        enabled: false
        text: "Змінити БД ["+root.dbname.substring(dbname.lastIndexOf('/')+1)+"]"
        onTriggered: {
            selectPopup.code = "database"
            selectPopup.jsdata = Lib.getDbList(Db, applicationDirPath);
            selectPopup.open()
        }
    }

    Action {
        id: crntRepoAction
        text: qsTr("Current report")
        onTriggered: stack.currentIndex = 0
    }

    Action {
        id: monRepoAction
        text: qsTr("Report by months")
        onTriggered: stack.currentIndex = 1
    }

    Action {
        id: yearRepoAction
        text: qsTr("Report by years")
        onTriggered: stack.currentIndex = 2
    }



    PopupSelect{
        id: selectPopup
        width:300
        height: root.height*0.8
        x: (root.width-width)/2

        Connections {
            target: selectPopup
            // function onClosing() { selectPopup.active = false; }
            function onVkEvent(id, param) {
                // dbg(String("code=%1 param=%2").arg(id).arg(param), "7wy")
                if (id === "database"){
                    // console.log("[MAIN>DcnView] dcmid=" + param.dcmid + " pid=" + param.pid)
                    root.dbname = param
                }
            }
        }

    }

    StackLayout {
        id: stack
        anchors{fill:parent; leftMargin: 5; rightMargin: 5}
        currentIndex: pager.currentIndex
        ItemCrnt{
            id: statCrnt
        }

        ItemMonth{
            id: statMonth
        }

        ItemYear{
            id: statYear
        }

        onCurrentIndexChanged: filterEdit.text = children[currentIndex].filter
    }

    PageIndicator {
        id: pager
        anchors.bottom: stack.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        // interactive: true
        currentIndex: stack.currentIndex
        count: stack.count

    }

    LogView{
        id: logView
        width: parent.width
        height: (count * 25 < parent.height / 4) ? count * 25 : parent.height / 4
        z: 10
        anchors.bottom: parent.bottom
        debug: true
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "☰"
                onClicked: naviMenu.open()
                Menu {
                    id: naviMenu
                    y: parent.height
                    MenuItem { action: crntRepoAction; }
                    MenuItem { action: monRepoAction; }
                    MenuItem { action: yearRepoAction; }
                }
            }
            Label{
                Layout.fillWidth: true
                font.pixelSize: 20
                text: stack.children[stack.currentIndex].title
            }


            TextField{
                id: filterEdit
                Layout.preferredWidth: 100
//                    focus: true
                selectByMouse: true
                onActiveFocusChanged: if (activeFocus) {selectAll()}
                horizontalAlignment: Text.AlignHCenter
                placeholderText: "filter"
                // text: vw.vfilter
                // onAccepted: {
                onEditingFinished: {
                    stack.children[stack.currentIndex].filter = text
                }
            }

            ToolButton {
                // id: contextMenu
                text: "⋮"
                onClicked: contextMenu.open()
                Menu {
                    id: contextMenu
                    y: parent.height
                    onVisibleChanged: {
                        let i =0
                        if (visible){
                            if (stack.children[stack.currentIndex].vkContextActions !== undefined){
                                  for (i =0; i < stack.children[stack.currentIndex].vkContextActions.length; ++i){
                                      contextMenu.addAction(stack.children[stack.currentIndex].vkContextActions[i])
                                  }
                            }
                            if (stack.children[stack.currentIndex].vkContextOptionalActions !== undefined
                                    && stack.children[stack.currentIndex].vkContextOptionalActions.length !== 0){
                                contextMenu.addItem( Qt.createQmlObject('import QtQuick.Controls; MenuSeparator {}',
                                                                                              contextMenu.contentItem,
                                                                                              "dynamicSeparator") )
                                for (i =0; i < stack.children[stack.currentIndex].vkContextOptionalActions.length; ++i){
                                    contextMenu.addAction(stack.children[stack.currentIndex].vkContextOptionalActions[i])
                                }
                            }
                            if (stack.children[stack.currentIndex].vkContextMenu !== undefined){
                                contextMenu.addItem( Qt.createQmlObject('import QtQuick.Controls; MenuSeparator {}',
                                                                                              contextMenu.contentItem,
                                                                                              "dynamicSeparator") )
                                contextMenu.addMenu(stack.children[stack.currentIndex].vkContextMenu)
                            }

/*                            contextMenu.addItem( Qt.createQmlObject('import QtQuick.Controls; MenuSeparator {}',
                                                                                          contextMenu.contentItem,
                                                                                          "dynamicSeparator") )
                            for (i =0; i < stack.count; ++i) {
                                contextMenu.addAction(activateBind.createObject(contextMenu,
                                                                                { cindex: i,
                                                                                  text: String(i === stack.currentIndex ? "<b>%1. %2</b>" : "%1. %2").arg(i).arg(stack.children[i].textForMenu())
                                                                                }))

                            } */
                        } else {
                            for (i =contextMenu.count -1; i >=0; --i) contextMenu.removeItem(contextMenu.itemAt(i))
                        }

                    }
                }
            }
        }

    }


    footer: Rectangle{
        width: parent.width
        height: 25  //childrenRect.height
        color: 'lightgray'
        RowLayout{
            anchors{fill: parent; leftMargin: 10; rightMargin: 10}
            Label {
                id: footerLeftLabel
                width: 50
                clip: true
                // elide: Text.ElideLeft
                // text: root.dbname
                text: String("...%1@%2")
                .arg(root.dbname.substring(root.dbname.length - 30))
                .arg("")
            }
        }

    }

    Component.onCompleted: {
        // let p = "f26r"    //"s5k9";
        // console.log("#387y psw = " + p + " b64: " + Qt.btoa( p));
        // console.log("env=")
        // console.log(applicationDirPath)
        // console.log("+++")
        // bindCheckAction.trigger()
        // pathToDb = "./data/"
        // pathToDb = applicationDirPath + "/data/"
//         var dbList = Db.dirEntryList(pathToDb,'*.sqlite', 2,0)
// //            console.log('main db list='+dbList)
        const dbList = Lib.getDbList(Db, applicationDirPath)
        if (dbList.length === 1) {
            // root.dbname = pathToDb+dbList[0]
            root.dbname = dbList[0].id
            // openConnection(pathToDb+dbList[0])
        } else if (dbList.length > 1) {
            changeDBAction.enabled = true
            changeDBAction.trigger()

        } else {        // no database
            // error
            logView.append("Недоступна база даних", 0)
        }

    }
}

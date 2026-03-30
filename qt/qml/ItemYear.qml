import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 720
    height: 480
    property string title
    property string filter
    onFilterChanged: {/*dbg("filter", "937");*/vw.load()}
    property list<string> years: []
    property var db                 // DataBase driver
    onDbChanged: {
        // console.log("StatView db changed")
                   // root.title = "Cost by month"
        // vw.load()
        // dataModel.load(db, "qty")
    }

    function dbg(str, code ="") {
        console.log( String("[ItemYear.qml]#%1 %2").arg(code).arg(str));
    }

    property list<Action> vkContextActions: [
                   loadCostAction,
                   loadQtyAction
    ]

    property list<Action> vkContextOptionalActions: [
        // uahToAcntAction,
    ]

    property Menu vkContextMenu : Menu{
        title: "Years"
        Repeater {
               model: root.years
               MenuItem {
                   required property string modelData
                   text: String("%1").arg(modelData)
                   onTriggered: {vw.year = modelData; vw.load();}
               }
    }
    }

    Action {
        id: loadCostAction
        text: qsTr("Cost by years")
        onTriggered: {
            vw.repo = "cost"
            // vw.load()
        }
    }

    Action {
        id: loadQtyAction
        text: qsTr("Qty by years")
        onTriggered: {
            // dbg("loadQtyAction","ew7h")
            vw.repo = "qty"
            // vw.load()
        }
    }

    ModelYear{
        id: dataModel
    }

    Component {
        id: dlg
        FocusScope {
            id: root
            width: root.ListView.view.width //childrenRect.width;
            height: 28;
            Rectangle{
                anchors{fill:parent}
                clip: true
                Row{
                   anchors{fill:parent}
                    // width: parent.width
                    spacing: 5
                    // anchors{fill: parent;}
                    Row{
                        width: root.ListView.view.headerItem.children[0].children[0].width
                        height: parent.height
                        clip: true
                        Row{
                            width: root.ListView.view.headerItem.children[0].children[0].children[0].width
                            height: parent.height
                            spacing: 0
                            Item {
                                id: shift
                                width: 10 * Math.floor((pathid.length) / 6)
                                height: parent.height
                            }
                            ToolButton{
                                height: 20         //parent.height
                                width: 20          //parent.height
                                // anchors{fill:parent}
                                // height: parent.width
                                enabled: child !== 0
                                text: child > 0 ? "+" : (child < 0 ? "-" : "")
                                onClicked: if (child > 0) root.ListView.view.expand(index)
                                else if (child < 0) root.ListView.view.collapse(index)
                                    // console.log(String("StatView#q55f i=%1 ch=%2").arg(index).arg(child))
                            }

                            Text{
                                width: parent.width - shift.width - parent.height
                                elide: Text.ElideRight
                                text: name         //     + "  " + (pathid.length-6)/
                                clip: true
                                MouseArea{
                                    anchors.fill: parent
                                    hoverEnabled :true
                                    ToolTip{
                                        id: nameToolTip
                                        // width: 150
                                        visible: false
                                        delay: 1000
                                        timeout: 5000
                                        text: 'код: '+ id
                                    }
                                    onEntered: {nameToolTip.visible = true}
                                    onExited: nameToolTip.visible = false
                                }
                            }

                        }

                        Text{
                            width: root.ListView.view.headerItem.children[0].children[0].children[1].width
                            horizontalAlignment: Text.AlignRight
                            font.bold: true
                            text: Number(total) === 0 ? "" : Number(total).toLocaleString(Qt.locale(), "f", 0)
                            // text: root.cellText(total)
                            clip: true
                        }

                    }
                    Row{
                        id: details
                        width: root.ListView.view.headerItem.children[0].children[1].width
                        spacing: 1
                        property real cellWidth: (width - 9 * spacing)/10
                        // Repeater {
                        //        model: 11
                        //        Text {
                        //            width: parent.cellWidth
                        //            horizontalAlignment: Text.AlignRight
                        //            text: root.ListView.view.model.get(index)["mon_" + String("%1%2").arg(modelData < 9 ? "0" : "").arg(modelData+1)]
                        //        }
                        // }
                        Text{
                            width: parent.cellWidth
                            horizontalAlignment: Text.AlignRight
                            text: root.ListView.view.cellText(index, 0)
                            clip: true
                        }
                        Text{
                            width: parent.cellWidth
                            horizontalAlignment: Text.AlignRight
                            text: root.ListView.view.cellText(index, 1)
                            clip: true
                        }
                        Text{
                            width: parent.cellWidth
                            horizontalAlignment: Text.AlignRight
                            text: root.ListView.view.cellText(index, 2)
                            clip: true
                        }
                        Text{
                            width: parent.cellWidth
                            horizontalAlignment: Text.AlignRight
                            text: root.ListView.view.cellText(index, 3)
                            clip: true
                        }
                        Text{
                            width: parent.cellWidth
                            horizontalAlignment: Text.AlignRight
                            text: root.ListView.view.cellText(index, 4)
                            clip: true
                        }
                        Text{
                            width: parent.cellWidth
                            horizontalAlignment: Text.AlignRight
                            text: root.ListView.view.cellText(index, 5)
                            clip: true
                        }
                        Text{
                            width: parent.cellWidth
                            horizontalAlignment: Text.AlignRight
                            text: root.ListView.view.cellText(index, 6)
                            clip: true
                        }
                        Text{
                            width: parent.cellWidth
                            horizontalAlignment: Text.AlignRight
                            text: root.ListView.view.cellText(index, 7)
                            clip: true
                        }
                        Text{
                            width: parent.cellWidth
                            horizontalAlignment: Text.AlignRight
                            text: root.ListView.view.cellText(index, 8)
                            clip: true
                        }
                        Text{
                            width: parent.cellWidth
                            horizontalAlignment: Text.AlignRight
                            text: root.ListView.view.cellText(index, 9)
                            clip: true
                        }
                    }

                }
            }

        }
    }


    Component {
        id: vwHeader
        Rectangle{
            id : root
            width: root.ListView.view.width //childrenRect.width;
            height: 30
            opacity: 0.7
            RowLayout{
                anchors{fill:parent}
                Row{
                   id: sideLeft
                   Layout.fillWidth: true
                   Layout.preferredWidth: parent.width * 0.35 - parent.spacing
                   spacing: 1
                   Item{
                       width: 0.75 * parent.width - parent.spacing
                       height: parent.height
                       Row{
                           anchors.horizontalCenter: parent.horizontalCenter
                          Label{
                             horizontalAlignment: Text.AlignHCenter
                             text: qsTr("Name")
                             MouseArea{
                                                anchors.fill: parent
                                                onDoubleClicked: root.ListView.view.sortOrder = "name"
                             }
                          }

                          ToolButton{
                             width: 20
                             height: 20
                             visible: root.ListView.view.sortOrder === "name"
                             text:"↓"
                          }
                       }
                   }

                   Row{
                      width: 0.25 * parent.width
                      Label{
                         horizontalAlignment: Text.AlignHCenter
                         text: qsTr("Total")
                         // background: Rectangle{color:"khaki"}
                         MouseArea{
                                            anchors.fill: parent
                                            onDoubleClicked: root.ListView.view.sortOrder = "total"
                         }
                      }
                      ToolButton{
                         width: 20
                         height: 20
                         visible: root.ListView.view.sortOrder === "total"
                         text:"↓"
                      }

                   }

                }
                Row{
                    id: details
                    Layout.preferredWidth: parent.width * 0.65
                    property real cellWidth: (width - 9 * spacing)/10
                    spacing: 1
                    Repeater {
                        model: 10
                        Label {
                            width: parent.cellWidth
                            horizontalAlignment: Text.AlignHCenter
                            text: (Number(root.ListView.view.year)-modelData).toFixed(0)
                        }
                    }
                }
            }

        }
    }


    ListView{
      id: vw
      property string sortOrder: "total" // total | name
      onSortOrderChanged: load()
      property string repo
      onRepoChanged: load()
      property string year: new Date().getFullYear()
      // onYearChanged: load()

      anchors{fill: parent}
                   spacing: 1
                   clip: true
                   header: vwHeader
                   model: dataModel
                   delegate: dlg
                   function load(){
                       // return
                                      // if (root.filter === undefined) return
                        // dbg("molel load flt=["+(root.filter===""? "EMPTY":"NO EMPTY")+"]","s78")
                       root.title = String("%1, %2")
                                      .arg(repo === "qty" ? loadQtyAction.text : loadCostAction.text)
                                      .arg(vw.year)
                       if (model.load(db,
                                      year || new Date().getFullYear(),
                                      repo || "cost",
                                      root.filter || ""))  model.addChild(sortOrder)
                   }

                   function expand(row){
                        // dbg("row="+row, "w09")
                        model.addChild(sortOrder, row)
                   }

                   function collapse(row){
                        model.removeChild(row)
                   }

                   function cellText(i,v) {
                       if (i < 0 || i >= model.count) return ""
                       // console.log("count=" + model.count + " i=" + i)
                       const cell = model.get(i)["y_" +  (Number(year)-v).toFixed(0)]
                       return cell === 0 ? "" : cell.toLocaleString(Qt.locale(), "f", 0);
                   }
    }


}

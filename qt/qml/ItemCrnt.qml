import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 720
    height: 480
    property string title : qsTr("Current report")
    property string filter: ""
    onFilterChanged: vw.load()
    property var db                 // DataBase driver
    onDbChanged: {
        // vw.load()
    }

    function dbg(str, code ="") {
        console.log( String("[ItemCrnt.qml]#%1 %2").arg(code).arg(str));
    }

    property list<Action> vkContextActions: [
        loadCrntAction,
    ]

    property list<Action> vkContextOptionalActions: [
        // uahToAcntAction,
    ]

    Action {
        id: loadCrntAction
        text: root.title
        onTriggered: {
            vw.load()
        }
    }

    Component {
        id: dlg
        FocusScope {
            id: root
            width: root.ListView.view.width //childrenRect.width;
            height: 28;
            function cellText(v) { return v === 0 ? "" : v.toFixed(0);}
            Rectangle{
                anchors{fill:parent}
                clip: true
                Row{
                   anchors{fill:parent}
                    // width: parent.width
                    spacing: 2
                   // anchors{fill: parent;}
                    Row{
                       width: root.ListView.view.headerItem.children[0].children[0].width
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
                          enabled: child !== 0
                          text: child > 0 ? "+" : (child < 0 ? "-" : "")
                          onClicked: if (child > 0) root.ListView.view.expand(index)
                          else if (child < 0) root.ListView.view.collapse(index)
                              // console.log(String("StatView#q55f i=%1 ch=%2").arg(index).arg(child))
                       }
                       // Item{
                       //    height: parent.height
                       //    width: parent.height
                       // }

                       Text{
                           width: parent.width - shift.width - parent.height
                           elide: Text.ElideRight
                           // text: "0="+root.ListView.view.headerItem.children[0].width
                           // + " 1=" + root.ListView.view.headerItem.children[0].children[0].width
                           // + " 2=" + root.ListView.view.headerItem.children[0].children[0].children[0].width
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
                        width: root.ListView.view.headerItem.children[0].children[1].width
                        horizontalAlignment: Text.AlignRight
                        // text: root.ListView.view.headerItem.children[0].children[3].width
                        text: code === "folder" ? "" : Number(qty).toLocaleString(Qt.locale(), "f", 0)
                        clip: true
                    }
                    Text{
                        width: root.ListView.view.headerItem.children[0].children[2].width
                        horizontalAlignment: Text.AlignRight
                        // font.bold: true
                        text: Number(cost).toLocaleString(Qt.locale(), "f", 0)
                        // text: root.ListView.view.headerItem.children[0].children[0].width
                        clip: true
                    }
                    Text{
                        width: root.ListView.view.headerItem.children[0].children[3].width
                        horizontalAlignment: Text.AlignRight
                        text: code === "folder" ? "" : Number(yearsellqty).toLocaleString(Qt.locale(), "f", 0)
                        clip: true
                    }
                    Text{
                        width: root.ListView.view.headerItem.children[0].children[4].width
                        horizontalAlignment: Text.AlignRight
                        text: Number(yearsellcost).toLocaleString(Qt.locale(), "f", 0)
                        clip: true
                    }
                    Text{
                        width: root.ListView.view.headerItem.children[0].children[5].width
                        horizontalAlignment: Text.AlignRight
                        text: outm.substring(0,10)
                        clip: true
                    }
                    Text{
                        width: root.ListView.view.headerItem.children[0].children[6].width
                        horizontalAlignment: Text.AlignRight
                        text: intm.substring(0,10)
                        clip: true
                    }
                    Text{
                        width: root.ListView.view.headerItem.children[0].children[7].width
                        horizontalAlignment: Text.AlignRight
                        text: code === "folder" ? "" : Number(bscprice).toFixed(2)
                        clip: true
                    }
                    Text{
                        width: root.ListView.view.headerItem.children[0].children[8].width
                        horizontalAlignment: Text.AlignRight
                        text: code === "folder" ? "" : Number(buyprice).toFixed(2)
                        clip: true
                    }
                    Text{
                        width: root.ListView.view.headerItem.children[0].children[9].width
                        horizontalAlignment: Text.AlignRight
                        text: code === "folder" ? "" : Number(sellprice).toFixed(2)
                        clip: true
                    }
                    Text{
                        width: root.ListView.view.headerItem.children[0].children[10].width
                        horizontalAlignment: Text.AlignRight
                        text: code === "folder" ? "" : Number(100*(sellprice-buyprice)/buyprice).toFixed(1)
                        clip: true
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
           Row{
              anchors{fill:parent}
              spacing: 2
              Item{
                  width: 0.4 * parent.width - parent.spacing
                  height: parent.height
                  Row{
                      anchors.horizontalCenter: parent.horizontalCenter
                     Label{
                        // horizontalAlignment: Text.AlignHCenter
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

              Label{
                width: 50
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Qty")
                // background: Rectangle{color:"khaki"}
              }
              Row{
                  width: 90
                 Label{
                    width: 70
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Cost")
                    // background: Rectangle{color:"blue"}
                    MouseArea{
                       anchors.fill: parent
                       onDoubleClicked: root.ListView.view.sortOrder = "cost"
                    }
                 }
                 ToolButton{
                    width: 20
                    height: 20
                    visible: root.ListView.view.sortOrder === "cost"
                    text:"↓"
                 }

              }
              Label{
                  width: 50
                  horizontalAlignment: Text.AlignHCenter
                  text: qsTr("Y-Qty")
                  // background: Rectangle{color:"khaki"}
              }
              Row{
                  // width: 90
                 Label{
                     width: 70
                     horizontalAlignment: Text.AlignHCenter
                     text: qsTr("Y-Cost")
                    MouseArea{
                       anchors.fill: parent
                       onDoubleClicked: root.ListView.view.sortOrder = "ysellcost"
                    }
                 }
                 ToolButton{
                    width: 20
                    height: 20
                    visible: root.ListView.view.sortOrder === "ysellcost"
                    text:"↓"
                 }

              }
              Row{
                  // width: 90
                 Label{
                     width: 80
                     horizontalAlignment: Text.AlignHCenter
                     text: qsTr("Out")
                    MouseArea{
                       anchors.fill: parent
                       onDoubleClicked: root.ListView.view.sortOrder = "outm"
                    }
                 }
                 ToolButton{
                    width: 20
                    height: 20
                    visible: root.ListView.view.sortOrder === "outm"
                    text:"↓"
                 }

              }
              Row{
                  // width: 90
                 Label{
                     width: 80
                     horizontalAlignment: Text.AlignHCenter
                     text: qsTr("In")
                    MouseArea{
                       anchors.fill: parent
                       onDoubleClicked: root.ListView.view.sortOrder = "intm"
                    }
                 }
                 ToolButton{
                    width: 20
                    height: 20
                    visible: root.ListView.view.sortOrder === "intm"
                    text:"↓"
                 }

              }
              Label{
                  width: 60
                  horizontalAlignment: Text.AlignHCenter
                  text: qsTr("Bsc")
                  // background: Rectangle{color:"khaki"}
              }
              Label{
                  width: 60
                  horizontalAlignment: Text.AlignHCenter
                  text: qsTr("Buy")
              }
              Label{
                  width: 60
                  horizontalAlignment: Text.AlignHCenter
                  text: qsTr("Sell")
              }
              Label{
                  width: 50
                  horizontalAlignment: Text.AlignHCenter
                  text: qsTr("MU%")
              }
           }

        }
    }

    ModelCrnt{
        id: dataModel
    }

    ListView{
      id: vw
      property string sortOrder: "cost" // cost | name
      onSortOrderChanged: load()

      anchors{fill: parent}
       spacing: 1
       clip: true
       header: vwHeader
       model: dataModel
       delegate: dlg

       function load(){
           root.title = qsTr("Current report ")
           if(model.load(root.db, root.filter)) model.addChild(sortOrder)
       }

       function expand(row){
                          // dbg("row="+row, "w09")
                          model.addChild(sortOrder, row)
       }

       function collapse(row){
                          model.removeChild(row)
       }

    }

}

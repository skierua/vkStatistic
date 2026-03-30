import QtQuick

import "../js/v146/sqlItem.js" as LibItem
import "../js/v146/sqlStatAcnts.js" as LibAcnts
import "../js/v146/sqlDocuments.js" as LibDocs

ListModel {
    id: root
    property var data: []

    function dbg(str, code ="") {
        console.log( String("[ModelCrnt.qml]#%1 %2").arg(code).arg(str));
    }

    function dummyRow(code = "item"){
        return {
            "id": "",
            "pid": "",
            "code": code,
            "pathid": "",
            "name": "",
            "pathname": "",
            "child": 0,
            "qty": 0,
            "cost": 0,
            "intm": "",
            "outm": "",
            "bscprice": 0,
            "buyprice": 0,
            "sellprice": 0,
            "yearbuyqty": 0,
            "yearbuycost": 0,
            "yearsellqty": 0,
            "yearsellcost": 0,
            // "": 0,
            // "": 0,
        }
    }

    function isAllowed(item, flt){
        const ok = (flt === undefined || flt === ""
                    || item.id === flt
                || ~(item.scancode).indexOf(flt)
                || ~(item.itemchar.toLowerCase()).indexOf(flt.toLowerCase())
                || ~(item.itemname.toLowerCase()).indexOf(flt.toLowerCase())
                || ~(item.itemnote.toLowerCase()).indexOf(flt.toLowerCase())
                );
        // if (ok) {
        //     dbg("["+ flt +"]\t" + item.id
        //         + "\t["+ item.scancode +"]"
        //         +"\t" +item.itemchar
        //         +"\t" +item.itemname
        //         +"\t[" +item.itemnote +"]"
        //         , "73h")
        // }

        return ok
    }

    function isEmpty(row){
        return (Math.abs(row.cost) < 0.5 && Math.abs(row.yearsellcost) < 0.5)
    }

    function load(db, flt = ""){
        root.clear();
        if (db === undefined) return;
        // dbg("load START", "s73")
        // dbg(String("y=%1 repo=%2").arg(year).arg(report), "s73")
        let r =0, lf =0, rt =0
        LibItem.fillFolderCache(db)
        let tmp = []
        LibItem.folderPathCache.forEach(v =>
                                       {
                                         let folder = dummyRow("folder")
                                           folder.id = v.id;
                                           folder.pid = v.pid;
                                           folder.pathid = v.pathid;
                                           folder.name = v.name;
                                           folder.pathname = v.pathname;
                                           tmp.push(folder)
                                       })
        const startItemIndex = tmp.length

        const acntBalance = LibAcnts.acntBalance(db, "3500")

        const tradeBalance = LibAcnts.tradeBalance(db, "3500")
        acntBalance.forEach(v => {
                              let i =0, lf =0, rt =tradeBalance.length -1;
                              while (lf <= rt) {    // BS
                                  i = Math.floor((rt + lf) / 2);
                                  if (v.id === tradeBalance[i].id) break
                                  if (Number(v.id) < Number(tradeBalance[i].id)) rt = i -1
                                  else lf = i+1
                              }
                                 // dbg(v.id + "\t" + v.itemid + "\t"
                                 //     + (v.id !== tradeBalance[i].id ? "--" : "Y") + "\t" +  tradeBalance[i].id + "\t" + tradeBalance[i].article + "\t"
                                 //     , "we63")
                            if (v.id !== tradeBalance[i].id) i = tradeBalance.length
                              // sequential search
                              // for (; i < tradeBalance.length && v.id !== tradeBalance[i].id; ++i) {}
                              if (i < tradeBalance.length) {
                                    v.eqtotal = Number(tradeBalance[i].total)
                                     v.bscprice = Number(tradeBalance[i].bscprice)
                                     v.buyprice = Number(tradeBalance[i].buyprice)
                                     v.sellprice = Number(tradeBalance[i].sellprice)
                              }
                          })
        const yearSells = LibDocs.lastYearSell(db)

        acntBalance.forEach(v => {
              // dbg(String("%1\t%2\t%3\t%4\t%5").arg(v.id).arg(v.pid).arg(v.qty).arg(v.cost).arg(v.dsc), "we63")
              let i =0, lf =0, rt =yearSells.length -1;
              while (lf <= rt) {    // BS
                  i = Math.floor((rt + lf) / 2);
                  if (v.itemid === yearSells[i].id) break
                  if (Number(v.itemid) < Number(yearSells[i].id)) rt = i -1
                  else lf = i+1
              }
              if (v.itemid !== yearSells[i].id) i = yearSells.length
              // sequential search
              // for (; i < yearSells.length && v.itemid !== yearSells[i].id; ++i) {}
              if (i < yearSells.length) {
                  v.yearsellqty = Number(yearSells[i].qty)
                  v.yearsellcost = Number(yearSells[i].cost)
                  // dbg(String("s-%1\ts-%2\ts-%3\t%4\t%5\t%6")
                  //     .arg(v.id).arg(v.qty).arg(v.cost).arg(tmp[i].id).arg(tmp[i].yearsellqty).arg(tmp[i].yearsellcost), "239d")
              }
          })


        // LibAcnts.reportData.forEach(v =>
        // {
        //     dbg(JSON.stringify(v), "sj6")
        // })
        let crntItem = LibItem.dummyItem()
        let crntPid = ""
        let crntMonth = -1

        for (r =0; r < acntBalance.length; ++r){
            crntItem = LibItem.getItemById(db, acntBalance[r].itemid)
            if (!isAllowed(crntItem, flt)) continue
            crntPid = crntItem.pid
            let row = dummyRow()
            row.id = crntItem.id
            row.pid = crntItem.pid
            row.pathid = crntItem.pathid
            row.name = crntItem.itemchar
            row.pathname = crntItem.pathname

            row.qty = Number(acntBalance[r].total)
            row.cost = Number(acntBalance[r].eqtotal)
            row.intm = acntBalance[r].intm
            row.outm = acntBalance[r].outm
            row.bscprice = Number(acntBalance[r].bscprice)
            row.buyprice = Number(acntBalance[r].buyprice)
            row.sellprice = Number(acntBalance[r].sellprice)
            row.yearsellqty = Number(acntBalance[r].yearsellqty) || 0
            row.yearsellcost = Number(acntBalance[r].yearsellcost) || 0
            if (!isEmpty(row)) tmp.push(row)
            // }
        }

        for (r = startItemIndex; r < tmp.length; ++r){
            // dbg(String("%1\t%2\t%3\t%4\t%5").arg(tmp[r].id).arg(tmp[r].pid).arg(tmp[r].yearsellqty).arg(tmp[r].yearsellcost).arg(""), "7wy")
            crntPid = tmp[r].pid
            while (crntPid !== ""){
                const idx = tmp.findIndex( (v) => v.id === crntPid )
                if (idx < 0) break;
                crntPid = tmp[idx].pid
                tmp[idx].child += 1
                tmp[idx].cost += Number(tmp[r].cost)
                tmp[idx].yearsellcost += Number(tmp[r].yearsellcost)
            }
        }

        // delete ZERO/EMPTY folders
        for (r = startItemIndex -1; r >=0; --r){
            if (!(Number(tmp[r].child) > 0)) tmp.splice(r,1)
        }

        root.data = tmp
        return true
    }

    function addChild(sortOrder, index =-1, deep = false){
        // dbg(String("i=%1 o=%2").arg(index).arg(sortOrder), "asu8")
        if (index === undefined) index = -1
        const pid = ( index === -1) ? "" : root.get(index).id
        if (index !== -1) root.get(index).child = 0 - root.get(index).child
        let tmp = []

        root.data.forEach(v => {
                              if (v.pid === pid) {
                                  if (!(v.code === "folder" && v.child === 0)
                                  || !(v.code === "item" && v.qty === 0 && v.cost === 0))  tmp.push(v)
                              }
                          })
        if (sortOrder === "name")
            tmp.sort((a,b) => {
                         if (a.code < b.code) return -1
                         else if (a.code > b.code) return 1
                         else if (a.name < b.name) return -1
                         return 1
                     } )
        else if (sortOrder === "ysellcost")
            tmp.sort((a,b) => {
                         if (a.code < b.code) return -1
                         else if (a.code > b.code) return 1
                         else if (Number(a.yearsellcost) > Number(b.yearsellcost)) return -1
                         else if (Number(a.yearsellcost) < Number(b.yearsellcost)) return 1
                         else if (a.name < b.name) return -1
                         return 1
                     } )
        else if (sortOrder === "outm")
            tmp.sort((a,b) => {
                         if (a.code < b.code) return -1
                         else if (a.code > b.code) return 1
                         else if (a.outm < b.outm) return -1
                         else if (a.outm > b.outm) return 1
                         else if (a.name < b.name) return -1
                         return 1
                     } )
        else if (sortOrder === "intm")
            tmp.sort((a,b) => {
                         if (a.code < b.code) return -1
                         else if (a.code > b.code) return 1
                         else if (a.intm < b.intm) return -1
                         else if (a.intm > b.intm) return 1
                         else if (a.name < b.name) return -1
                         return 1
                     } )
        else        // sort by cost
            tmp.sort((a,b) => {
                         if (a.code < b.code) return -1
                         else if (a.code > b.code) return 1
                         else if (Number(a.cost) > Number(b.cost)) return -1
                         else if (Number(a.cost) < Number(b.cost)) return 1
                         else if (a.name < b.name) return -1
                         return 1
                     } )


        tmp.forEach(v => {root.insert(++index, v);})
        // tmp.forEach(v => {
        //              dbg(String("%1\t%2\t%3\t%4\t%5")
        //                  .arg(v.id).arg(v.pid)
        //                  // .arg(v.pathid).arg(v.child).arg(v.sellprice)
        //                  .arg(v.yearsellqty).arg(v.yearsellcost).arg("")
        //                  // .arg(v.bscprice).arg(v.buyprice).arg(v.sellprice)
        //                  , "6eg")
        //              })

    }

    function removeChild(index, deep = false){
        // dbg(String("i=%1").arg(index), "9rj")
        // dbg("BEFORE=====", "9rj")
        // for (let r =0; r < root.count; ++r){
        //     dbg(String("%1\t%2\t%3\t%4")
        //         .arg(root.get(r).id).arg(root.get(r).pid).arg(root.get(r).pathid).arg(root.get(r).pathname), "87w")

        // }
        if (index === undefined) index = 0
        const pid = root.get(index).pathid + root.get(index).id + "/"
        // dbg(String("i=%1 pathid=%2").arg(index).arg(pid), "9rj")
        root.setProperty(index, "child", 0 - root.get(index).child)
        ++index
        while (index < root.count && root.get(index).pathid.substring(0,pid.length) === pid)
            root.remove(index)
        // for (let len = root.count;
        //      index < len && root.get(index).pathid.substring(0,pid.length) === pid;
        //      ++index) {
        //         root.remove(index)
        // }
        // dbg("AFTER =====", "9rj")
        // for (let rr =0; rr < root.count; ++rr){
        //     dbg(String("%1\t%2\t%3\t%4")
        //         .arg(root.get(rr).id).arg(root.get(rr).pid).arg(root.get(rr).pathid).arg(root.get(rr).pathname), "87w")

        // }
    }

}

import QtQuick

import "../js/v146/sqlItem.js" as LibItem
import "../js/v146/sqlStatAcnts.js" as LibAcnts

ListModel {
    id: root
    property var data
    // property string sortOrder: "total" // total | name

    function dbg(str, code ="") {
        console.log( String("[ModelAcnt.qml]#%1 %2").arg(code).arg(str));
    }

    function dummyRow(code = "item"){
        return {
            "id": "",
            "pid": "",
            "code": code,
            "pathid": "",
            "name": "",
            "pathname": "",
            "scan": "",
            "child": 0,
            "total": 0,
            "mon_01":0,
            "mon_02":0,
            "mon_03":0,
            "mon_04":0,
            "mon_05":0,
            "mon_06":0,
            "mon_07":0,
            "mon_08":0,
            "mon_09":0,
            "mon_10":0,
            "mon_11":0,
            "mon_12":0,
            // "data": [0,0,0,0,0,0,0,0,0,0,0,0],
        }
    }

    function isAllowed(item, flt){
        return (flt === undefined || flt === ""
                    || item.id === flt
                || ~(item.scancode).indexOf(flt)
                || ~(item.itemchar.toLowerCase()).indexOf(flt.toLowerCase())
                || ~(item.itemname.toLowerCase()).indexOf(flt.toLowerCase())
                || ~(item.itemnote.toLowerCase()).indexOf(flt.toLowerCase())
                );
    }

/*    function isEmpty(row){
        return (Math.abs(tmp[r].total) < 0.5
                && Math.abs(row.mon_01) < 0.5
                && Math.abs(row.mon_02) < 0.5
                && Math.abs(row.mon_03) < 0.5
                && Math.abs(row.mon_04) < 0.5
                && Math.abs(row.mon_05) < 0.5
                && Math.abs(row.mon_06) < 0.5
                && Math.abs(row.mon_07) < 0.5
                && Math.abs(row.mon_08) < 0.5
                && Math.abs(row.mon_09) < 0.5
                && Math.abs(row.mon_10) < 0.5
                && Math.abs(row.mon_11) < 0.5
                && Math.abs(row.mon_12) < 0.5
                )
    } */

    function load(db, year, report = "cost", flt = ""){
        root.clear();
        if (year === undefined || year === "") return
        // dbg("load START", "s73")
        // dbg(String("y=%1 repo=%2").arg(year).arg(report), "s73")
        let r =0, lf =0, rt =0
        LibItem.fillFolderCache(db)
        const tmp = LibItem.folderPathCache
        tmp.forEach(v =>
        {
            v.code = "folder"
            // v.scan = ""
            v.child = 0
            v.total = 0
                        v["mon_01"] = 0
                        v["mon_02"] = 0
                        v["mon_03"] = 0
                        v["mon_04"] = 0
                        v["mon_05"] = 0
                        v["mon_06"] = 0
                        v["mon_07"] = 0
                        v["mon_08"] = 0
                        v["mon_09"] = 0
                        v["mon_10"] = 0
                        v["mon_11"] = 0
                        v["mon_12"] = 0
            // v.data = [0,0,0,0,0,0,0,0,0,0,0,0]
            // v.data = []
            // for (let i =0; i < 12; ++i) v.data.push(0)
            // dbg(JSON.stringify(v), "87w")
        })
        const startItemIndex = tmp.length

        if (report === "qty") {
            LibAcnts.sellQtyByMonth(db, year)
            // LibAcnts.sellQty(db, year)
        } else {
            LibAcnts.sellCostByMonth(db, year)
            // LibAcnts.sellCost(db, year)
        }

        // LibAcnts.reportData.forEach(v =>
        // {
        //     dbg(JSON.stringify(v), "sj6")
        // })
        let crntItem = LibItem.dummyItem()
        let crntPid = ""
        // let crntMonth = -1
        for (r =0; r < LibAcnts.reportData.length; ++r){
            if (crntItem.id !== LibAcnts.reportData[r].itemid) {
                crntItem = LibItem.getItemById(db, LibAcnts.reportData[r].itemid)
                if (!isAllowed(crntItem, flt)) continue
                crntPid = crntItem.pid
                // crntMonth = Number(LibAcnts.reportData[r].bind)
                let row = dummyRow()
                row.id = crntItem.id
                row.pid = crntItem.pid
                row.pathid = crntItem.pathid
                row.name = crntItem.itemchar
                row.pathname = crntItem.pathname
                // row.scan = crntItem.scancode
                row.total = Number(LibAcnts.reportData[r].total)
                row["mon_"+ LibAcnts.reportData[r].bind] = Number(LibAcnts.reportData[r].total)
                tmp.push(row)
            }  else {
                let idx = tmp.length - 1
                tmp[idx].total += Number(LibAcnts.reportData[r].total)
                tmp[idx]["mon_"+ LibAcnts.reportData[r].bind] = Number(LibAcnts.reportData[r].total)

            }

        }
        // for (let row = tmp.length-1; row >=0; -- row){
        //     if (tmp[row].code === "folder" && tmp[row].child === 0) tmp.splice(row, 1)
        // }
        // remove empty rows
        for (r = tmp.length -1; r > startItemIndex -1; --r){
            if (Math.abs(tmp[r].total) < 0.5
                    && Math.abs(tmp[r].mon_01) < 0.5
                    && Math.abs(tmp[r].mon_02) < 0.5
                    && Math.abs(tmp[r].mon_03) < 0.5
                    && Math.abs(tmp[r].mon_04) < 0.5
                    && Math.abs(tmp[r].mon_05) < 0.5
                    && Math.abs(tmp[r].mon_06) < 0.5
                    && Math.abs(tmp[r].mon_07) < 0.5
                    && Math.abs(tmp[r].mon_08) < 0.5
                    && Math.abs(tmp[r].mon_09) < 0.5
                    && Math.abs(tmp[r].mon_10) < 0.5
                    && Math.abs(tmp[r].mon_11) < 0.5
                    && Math.abs(tmp[r].mon_12) < 0.5
                    ){
                             tmp.splice(r,1)
                         }
        }

        for (r = startItemIndex; r < tmp.length; ++r){
            crntPid = tmp[r].pid
            while (crntPid !== ""){
                const idx = tmp.findIndex( (v) => v.id === crntPid )
                if (idx < 0) break;
                crntPid = tmp[idx].pid
                tmp[idx].child += 1
                if (report === "cost"){
                    for (let i =1; i < 13; ++i){
                        tmp[idx].total += tmp[r][String("mon_%1%2").arg(i < 10 ? "0" : "").arg(i)]
                        tmp[idx][String("mon_%1%2").arg(i < 10 ? "0" : "").arg(i)] += tmp[r][String("mon_%1%2").arg(i < 10 ? "0" : "").arg(i)]
                    }

                    // tmp[idx]["mon_"+LibAcnts.reportData[r].bind] += Number(LibAcnts.reportData[r].total)


                }
                // tmp[idx].data[crntMonth - 1] += Number(LibAcnts.reportData[r].total)
            }
        }

        // delete ZERO/EMPTY folders
        for (r = startItemIndex -1; r >=0; --r){
            if (!(Number(tmp[r].child) > 0)) tmp.splice(r,1)
        }


        root.data = tmp
        // root.data.forEach(v =>
        // {
        //     // dbg(JSON.stringify(v), "87w")
        //     dbg(String("%1\t%2\t%3\t%4\t%5").arg(v.id).arg(v.pid).arg(v.pathid).arg(v.pathname).arg(v.name), "87w")
        // })

        // populate()
        // addChild()
        return true
    }

    function addChild(sortOrder, index =-1, deep = false){
        // dbg(String("i=%1").arg(index), "asu8")
        if (index === undefined) index = -1
        const pid = ( index === -1) ? "" : root.get(index).id
        if (index !== -1) root.get(index).child = 0 - root.get(index).child
        let tmp = []

        root.data.forEach(v => {
                              if (v.pid === pid)
                              if (v.code !== "folder" || v.child !== 0) tmp.push(v)
                          })
        if (sortOrder === "name")
            tmp.sort((a,b) => {
                         if (a.code < b.code) return -1
                         else if (a.code > b.code) return 1
                         else if (a.name < b.name) return -1
                         return 1
                     } )
        else        // sort by total
            tmp.sort((a,b) => {
                         if (a.code < b.code) return -1
                         else if (a.code > b.code) return 1
                         else if (Number(a.total) > Number(b.total)) return -1
                         else if (Number(a.total) < Number(b.total)) return 1
                         else if (a.name < b.name) return -1
                         return 1
                     } )


        tmp.forEach(v => {root.insert(++index, v);})
        // tmp.forEach(v => {
        //              dbg(String("%1\t%2\t%3\t%4")
        //                  .arg(v.id).arg(v.pid).arg(v.pathid).arg(v.child), "87w")
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

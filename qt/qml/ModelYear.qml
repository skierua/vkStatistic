import QtQuick

import "../js/v146/sqlItem.js" as LibItem
import "../js/v146/sqlStatAcnts.js" as LibAcnts

ListModel {
    id: root
    property var data
    // property string sortOrder: "total" // total | name

    function dbg(str, code ="") {
        console.log( String("[ModelYear.qml]#%1 %2").arg(code).arg(str));
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

    function load(db, year, report, flt = ""){

        let dummyRow = (c,y)=>{
            let row = {
                "id": "",
                "pid": "",
                "code": c,
                "pathid": "",
                "name": "",
                "pathname": "",
                "scan": "",
                "child": 0,
                "total": 0
            }
            for (let i =0; i < 10; ++i){
                row["y_"+ (Number(y) - i).toFixed(0)] = 0
            }
            return row
        }

        const yearFrom = (Number(year)-9).toFixed(0)
        root.clear();
        let ny = Number(year)
        let r =0, lf =0, rt =0
        LibItem.fillFolderCache(db)
        const tmp = LibItem.folderPathCache
        tmp.forEach(v =>
        {
            v.code = "folder"
            // v.scan = ""
            v.child = 0
            v.total = 0
            for (let i =0; i < 10; ++i){
                v["y_"+ (ny - i).toFixed(0)] = 0
            }
        })
        // dbg(JSON.stringify(tmp), "etg3")
        const startItemIndex = tmp.length

        if (report === "qty") {
            LibAcnts.sellQtyByYear(db, yearFrom, year)
            // LibAcnts.sellQty(db, year)
        } else {
            LibAcnts.sellCostByYear(db, yearFrom, year)
            // LibAcnts.sellCost(db, year)
        }
        let crntItem = LibItem.dummyItem()
        let crntPid = ""
        // let crntBind = -1
        for (r =0; r < LibAcnts.reportData.length; ++r){
            if (crntItem.id !== LibAcnts.reportData[r].itemid) {
                crntItem = LibItem.getItemById(db, LibAcnts.reportData[r].itemid)
                if (!isAllowed(crntItem, flt)) continue
                crntPid = crntItem.pid
                // crntBind = Number(LibAcnts.reportData[r].bind)
                let row = dummyRow("item", year)
                row.id = crntItem.id
                row.pid = crntItem.pid
                row.pathid = crntItem.pathid
                row.name = crntItem.itemchar
                row.pathname = crntItem.pathname
                // row.scan = crntItem.scancode
                row.total = Number(LibAcnts.reportData[r].total)
                row["y_"+ LibAcnts.reportData[r].bind] = Number(LibAcnts.reportData[r].total)
                tmp.push(row)
            }  else {
                let idx = tmp.length - 1
                tmp[idx].total += Number(LibAcnts.reportData[r].total)
                tmp[idx]["y_"+ LibAcnts.reportData[r].bind] = Number(LibAcnts.reportData[r].total)
            }
        }
        for (r = tmp.length -1; r > startItemIndex -1; --r){
            if (Math.abs(tmp[r].total) < 0.5
                    // TODO
                    // && Math.abs(tmp[r].mon_01) < 0.5
                    // && Math.abs(tmp[r].mon_02) < 0.5
                    // && Math.abs(tmp[r].mon_03) < 0.5
                    // && Math.abs(tmp[r].mon_04) < 0.5
                    // && Math.abs(tmp[r].mon_05) < 0.5
                    // && Math.abs(tmp[r].mon_06) < 0.5
                    // && Math.abs(tmp[r].mon_07) < 0.5
                    // && Math.abs(tmp[r].mon_08) < 0.5
                    // && Math.abs(tmp[r].mon_09) < 0.5
                    // && Math.abs(tmp[r].mon_10) < 0.5
                    // && Math.abs(tmp[r].mon_11) < 0.5
                    // && Math.abs(tmp[r].mon_12) < 0.5
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

                    for (let i =0; i < 10; ++i){
                        tmp[idx].total += tmp[r]["y_"+ (ny - i).toFixed(0)]
                        tmp[idx]["y_"+ (ny - i).toFixed(0)] += tmp[r]["y_"+ (ny - i).toFixed(0)]
                    }

                    // tmp[idx]["y_"+LibAcnts.reportData[r].bind] += Number(LibAcnts.reportData[r].total)


                }
                // tmp[idx].data[crntMonth - 1] += Number(LibAcnts.reportData[r].total)
            }
        }

        // delete ZERO/EMPTY folders
        for (r = startItemIndex -1; r >=0; --r){
            if (!(Number(tmp[r].child) > 0)) tmp.splice(r,1)
        }

        // tmp.forEach(v =>
        // {
        //     // dbg(JSON.stringify(v), "s46")
        //     if (v.code === "folder")
        //     dbg(String("%1\t%2\t%3\t%4\t%5\t%6").arg(v.code).arg(v.id).arg(v.pid).arg(v.pathid).arg(v.name).arg(v.child), "45t")
        // })

        root.data = tmp

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
        //         .arg(root.get(r).id).arg(root.get(r).pid).arg(root.get(r).pathid).arg(root.get(r).pathname), "1d3")

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
        //         .arg(root.get(rr).id).arg(root.get(rr).pid).arg(root.get(rr).pathid).arg(root.get(rr).pathname), "245")

        // }
    }

}

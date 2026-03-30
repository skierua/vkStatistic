.pragma library
/**
  JS library
*/
// cache for data
let reportData = [];
// cache for data
let reportCode = "";
// cache for strgAcntYears
let strgAcntYears = [];

function acntBalance(db, acnt){
    if (acnt.length < 2) return []
    const reverse = (acnt.substring(0,2) !== "30" ? true : false)
    // const flt = "" + (String("substr(acntno,1,%1)='%2' %3 %4").arg(bal.length).arg(bal))
    const flt = "" + (String("acntno ='%1' AND abs(total) > 0.0009")
                      .arg(acnt))
        // .arg(" AND (abs(total) > 0.0009 OR dbtupd>date(coalesce((select max(shftdate) from shift),date('now')), '-0 days')")
        // .arg(" OR  cdtupd > date(coalesce((select max(shftdate) from shift),date('now')), '-0 days'))")
    return dbBalance(db, flt, "id", reverse)
}

function tradeBalance(db, bal = "3500"){
    if (bal.length < 2) return []
    const flt = (String("substr(acntrade.acntno,1,%1)='%2'").arg(bal.length).arg(bal))
    return dbTradeBalance(db, flt)
}

// Trade Quantity for year
function sellQtyByMonth(db, year, bal ="3500"){
    const code = String("sellQtyMon:%1:%2").arg(year).arg(bal)
    if (code === reportCode) return true
    reportCode = code
    const bind = "substr(shftdate,6,2)"
    const sumData = "turndbt"
    const flt =  String("substr(acntno,1,%1)='%2' AND substr(shftdate,1,4) = '%3'").arg(bal.length).arg(bal).arg(year)

    return dbAcntTurnover(db, bind, sumData, flt)
}

function sellCostByMonth(db, year, bal ="3500"){
    const code = String("sellCostMon:%1:%2").arg(year).arg(bal)
    if (code === reportCode) return true
    reportCode = code
    const bind = "substr(shftdate,6,2)"
    const sumData = "turncdt"
    const flt =  String("substr(acntrade.acntno,1,%1)='%2' AND substr(shftdate,1,4) = '%3'").arg(bal.length).arg(bal).arg(year)

    return dbTradeAcntTurnover(db, bind, sumData, flt)
}

function sellQtyByYear(db, start, finish, bal ="3500"){
    const code = String("sellQtyYear:%1:%2").arg(start).arg(bal)
    if (code === reportCode) return true
    reportCode = code
    const bind = "substr(shftdate,1,4)"
    const sumData = "turndbt"
    const flt =  String("substr(acntno,1,%1)='%2' AND substr(shftdate,1,4) >= '%3' AND substr(shftdate,1,4) <= '%4'").arg(bal.length).arg(bal).arg(start).arg(finish)

    // console.log("sqlStatAcntd/sellQtyByYear #949")

    return dbAcntTurnover(db, bind, sumData, flt)
}

function sellCostByYear(db, start, finish, bal ="3500"){
    const code = String("sellCostYear:%1:%2").arg(start).arg(bal)
    if (code === reportCode) return true
    reportCode = code
    const bind = "substr(shftdate,1,4)"
    const sumData = "turncdt"
    const flt =  String("substr(acntrade.acntno,1,%1)='%2' AND substr(shftdate,1,4) >= '%3' AND substr(shftdate,1,4) <= '%4'").arg(bal.length).arg(bal).arg(start).arg(finish)

    return dbTradeAcntTurnover(db, bind, sumData, flt)
}

// Quantity turnover for year
function dbAcntTurnover(db, bind, sumData, flt = ""){
    if (db === undefined) {
        reportData = []
        return false;
    }
    const vsql = "SELECT " + bind + "  AS bind, item itemid, sum(" + sumData + ") total FROM strgacnt JOIN shift ON(id = shftid)"
               +  (flt === "" ? "" : (" WHERE " + flt))
               + " GROUP BY item, bind HAVING total != 0;"
    try {
        const res = JSON.parse(db.dbSelectRows(vsql));
        // console.log("sqlAcnts #91j data")
        // console.log("sqlAcnts #91j vsql=" + vsql)
        // res.rows.forEach(v => console.log(v.bind + "\t" + v.itemid + "\t" + v.dbt + "\t" + v.cdt))
        reportData = res.rows;
    } catch (err) {
        console.log("sqlStatAcnts/dbAcntTurnover #w8j err=" + err)
        console.log("qry=" + vsql)
        reportData = []
        return false;
    }
    return true
}

// Quantity turnover for year
function dbTradeAcntTurnover(db, bind, sumData, flt = ""){
    if (db === undefined) {
        reportData = []
        return false;
    }
    const vsql = "SELECT " + bind + "  AS bind, article as itemid, sum(" + sumData + ") total "
    + " FROM acntrade JOIN strgacnt ON (eqid = acntid) JOIN shift ON(id = shftid)"
               +  (flt === "" ? "" : (" WHERE " + flt))
               + " GROUP BY article, bind HAVING total != 0;"
    try {
        const res = JSON.parse(db.dbSelectRows(vsql));
        // console.log("sqlAcnts #7qh data")
        // console.log("sqlStatAcnts/dbTradeAcntTurnover #7qh vsql=" + vsql)
        // res.rows.forEach(v => console.log(v.id + "\t" + v.acntno + "\t" + v.item + "\t" + v.total + "\t" + v.note))
        reportData = res.rows;
    } catch (err) {
        console.log("sqlStatAcnts/dbTradeAcntTurnover #w8j err=" + err)
        console.log("qry=" + vsql)
        reportData = []
        return false;
    }
    return true
}




function dbBalance(db, flt = "", order = "", reverse = false){
    if (db === undefined) return []
    // console.log("sqlAcnts #y37 reverse=" + reverse + " comp=" + (reverse === false))
    let amount = " (beginamnt+turndbt-turncdt) as total, coalesce(turndbt, '') income, coalesce(turncdt, '') outcome, coalesce(dbtupd, '') intm, coalesce(cdtupd, '') outm,"
    if (reverse) { amount = " (0 - (beginamnt+turndbt-turncdt)) as total, coalesce(turncdt, '') income, coalesce(turndbt, '') outcome, coalesce(cdtupd, '') intm, coalesce(dbtupd, '') outm,"; }
    const vsql = "select id, acntno, coalesce(item, '') itemid," + amount
            + " coalesce(client, '') clid, coalesce(acntbal.acntnote,'') note, coalesce(acntbal.mask,'') mask, coalesce(acntbal.trade,'') trade, balname "
            + " from acnt left join acntbal using(acntno) LEFT JOIN balname ON (substr(acntno,1,2) = bal) "
            +  (flt === "" ? "" : (" WHERE " + flt))
            +  (order === "" ? ";" : (" ORDER BY  " + order + ";"))
    // .arg(" AND (abs(total) > 0.0009 OR dbtupd>date(coalesce((select max(shftdate) from shift),date('now')), '-0 days')")
    // .arg(" OR  cdtupd > date(coalesce((select max(shftdate) from shift),date('now')), '-0 days'))")

    try {
        const res = JSON.parse(db.dbSelectRows(vsql));
        // console.log("sqlAcnts #28747 data")
        // console.log("sqlAcnts #28747 vsql=" + vsql)
        // res.rows.forEach(v => console.log(v.id + "\t" + v.acntno + "\t" + v.item + "\t" + v.total + "\t" + v.note))
        return res.rows;
    } catch (err) {
        console.log("sqlAcnts #ai8 err=" + err)
        console.log("qry=" + vsql)
        return [];
    }
}

function dbTradeBalance(db, flt =""){
    const vsql = "SELECT acntrade.pkey id, eqid, (beginamnt+turndbt-turncdt) total, bscprice, lastpricebuy buyprice, lastpricesell sellprice, article"
    + " FROM acntrade JOIN acnt ON (eqid=acnt.id)"
              + (flt === "" ? "" : (" WHERE "+ flt)) + " ORDER BY id;";
    try {
        // console.log("sqlAcnts/dbTradeBalance sql=" + vsql)
        const res = JSON.parse(db.dbSelectRows(vsql));
        return res.rows;
    } catch (err) {
        console.log("sqlAcnts/dbTradeBalance err=" + err)
        console.log("qry=" + vsql)
        return [];
    }

}

function dbStrgAcntYears(db, bal = ""){
    let res = []
    const vsql = String("SELECT DISTINCT substr(shftdate,1,4) AS year FROM strgacnt JOIN shift ON(id = shftid) %1 ORDER BY year DESC;")
    .arg(bal === "" ? "" : ("WHERE acntno = '" + bal + "'"))
    try {
        const dbres = JSON.parse(db.dbSelectRows(vsql));
        for (let i =0; i < dbres.rows.length; ++i) res.push(dbres.rows[i].year)
        // console.log("sqlAcnts/dbStrgAcntYears #7eh a=" + JSON.stringify(strgAcntYears))
        return res
    } catch (err) {
        console.log("sqlAcnts/dbStrgAcntYears #7eh err=" + err)
        console.log("qry=" + vsql)
        return res
    }
}

/* function dbTradeRemaind(db, bal="3500"){
    const vsql = "SELECT acnt.item item, (0 - (beginamnt+turndbt-turncdt)) total, eqtotal, cdtupd intm, dbtupd outm, bscprice, lastpricebuy buyprice, lastpricesell sellprice"
            + " FROM acnt LEFT JOIN acntrade ON (acnt.id = acntrade.pkey) LEFT JOIN"
            + " (SELECT id, (beginamnt+turndbt-turncdt) eqtotal FROM acnt WHERE substr(acntno,1,4)='eqvl') eq ON (eq.id = eqid)"
            + String(" WHERE substr(acnt.acntno,1,%1)='%2' and acnt.item is not NULL ORDER BY acnt.item;").arg(bal.length).arg(bal)
    try {
        const res = JSON.parse(db.dbSelectRows(vsql));
        for (let i =0; i < res.rows.length; ++i) strgAcntYears.push(res.rows[i].year)
        // console.log("sqlAcnts/dbTradeRemaind #5td a=" + JSON.stringify(strgAcntYears))
        return res.rows;
    } catch (err) {
        console.log("sqlAcnts/dbTradeRemaind #5td err=" + err)
        console.log("qry=" + vsql)
        return []
    }
} */


function acntbal (db, flt = ""){
    const vsql = "select acntno, coalesce(client, '') client, acntnote, mask, trade from acntbal "
              + (flt === "" ? "" : (" WHERE "+ flt)) + " ORDER BY acntno;";
    try {
        const res = JSON.parse(db.dbSelectRows(vsql));
        return res.rows;
    } catch (err) {
        console.log("sqlAcnts/acntbal err=" + err)
        console.log("qry=" + vsql)
        return [];
    }
}





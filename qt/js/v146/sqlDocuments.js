.pragma library

function lastYearSell(db) {
    const res = dbIntervalSum(db, " WHERE dcmtype = 'trade:sell' AND dcmtime > DATE( 'now', 'localtime', '-1 YEAR' )")
    return res
}


function dbIntervalSum(db, flt=""){
    const vsql = "SELECT item.pkey id, item.parentid pid, sum(0-amount) qty, sum(0-eqamount) cost, sum(discount) dsc, sum(bonus) bns"
            + " FROM strgdocum JOIN item ON (item = item.pkey)"
            + flt + " GROUP BY id;"
    try {
        const res = JSON.parse(db.dbSelectRows(vsql));
        // console.log("sqlDocuments/dbIntervalSell #6ag a=" + JSON.stringify(strgAcntYears))
        return res.rows;
    } catch (err) {
        console.log("sqlDocuments/dbIntervalSell #91h err=" + err)
        console.log("qry=" + vsql)
        return []
    }
}

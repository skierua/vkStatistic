.pragma library

// function func() {

// }

function getDbList(db, path =""){
  const pathToDb = path + "/data/"
  const dbList = db.dirEntryList(pathToDb,'*.sqlite', 2,0)
           // console.log("std.js db path=" + pathToDb + " list="+dbList)
  let vj = [];
  for (let i = 0; i < dbList.length; ++i){
      vj[i] = {'id':pathToDb+dbList[i], 'name':dbList[i],"fullname":'', 'mask':"256", "sect":'Доступні БД'};
//                    databaseView.model.append({'id':pathToDb+dbList[i], 'name':dbList[i]})
  }
  return vj
}

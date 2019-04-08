import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
final TABLE="vault",ID="id",SERVICE="service",USERNAME="username",PASSWORD="password";
class DBHelper {
  static final DBHelper _instance=DBHelper.internal();
  factory DBHelper()=>_instance;
  static Database _db;
  Future<Database> get db async{
    if(_db!=null) return _db;
    else{
      _db=await initDb();
      return _db;
    }
  }
  DBHelper.internal();
  initDb()async{
    var dbPath=await getDatabasesPath();
    return await openDatabase(join(dbPath,"maindb.db"), version: 1, onCreate: _onCreate);
  }
  _onCreate(Database db, int newVer)async{
    await db.execute("CREATE TABLE $TABLE($ID INTEGER PRIMARY KEY,$SERVICE TEXT,$USERNAME TEXT,$PASSWORD TEXT)");
  }
  Future<int> saveEntry(Entry e)async{
    var dbClient = await db;
    return await dbClient.insert(TABLE,e.toMap());
  }
  Future<List> getAll()async{
    var dbClient= await db;
    return await dbClient.rawQuery("SELECT * FROM $TABLE");
  }
  Future<int> deleteEntry(int id)async{
    var dbClient=await db;
    return await dbClient.delete(TABLE,where: "$ID=?",whereArgs:[id]);
  }
}

class Entry{
  String _service,_username,_password;
  int _id;
  Entry(this._service,this._username,this._password);
  Map<String,dynamic> toMap(){
    var map=Map<String,dynamic>();
    map[SERVICE]=_service;
    map[USERNAME]=_username;
    map[PASSWORD]=_password;
    if(_id!=null) map[ID]=_id;
    return map;
  }
}
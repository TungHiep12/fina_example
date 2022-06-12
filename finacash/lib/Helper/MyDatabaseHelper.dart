

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

  final String movimentacaoTABLE = "movimentacaoTABLE";
  final String idColumn = "idColumn";
  final String dataColumn = "dataColumn";
  final String valorColumn = "valorColumn";
  final String tipoColumn = "tipoColumn";
  final String descricaoColumn = "descricaoColumn";
  

class MySqlDataBaseHelper{

  static final MySqlDataBaseHelper _instance = MySqlDataBaseHelper.internal();

  factory MySqlDataBaseHelper() => _instance;

  MySqlDataBaseHelper.internal();

  Database _db;

  Future<Database> get db async{
    if(_db != null){
      return _db;
    }else{
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb()async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "movimentacao.db");

  return await openDatabase(path,version: 1,onCreate: (Database db,int newerVersion)async{
      await db.execute(
        "CREATE TABLE $movimentacaoTABLE(" +
        "$idColumn INTEGER PRIMARY KEY,"+
        "$valorColumn FLOAT,"+
        "$dataColumn TEXT,"+
        "$tipoColumn TEXT,"+
        "$descricaoColumn TEXT)"
            
      );
    });
  }

  Future<MoneyItem> saveMoneyItem(MoneyItem movimentacoes)async{
    print("chamada save");
    Database dbMovimentacoes = await db;
    movimentacoes.id = await dbMovimentacoes.insert(movimentacaoTABLE, movimentacoes.toMap());
    return movimentacoes;
  }

  Future<MoneyItem> getMoneyItem(int id)async{
    Database dbMovimentacoes = await db;
    List<Map> maps = await dbMovimentacoes.query(movimentacaoTABLE,
    columns: [idColumn,valorColumn, dataColumn, tipoColumn,descricaoColumn],
    where: "$idColumn =?",
    whereArgs: [id]);

    if(maps.length > 0){
      return MoneyItem.fromMap(maps.first);
    }else{
      return null;
    }
  }

  Future<int> deleteMovimentacao(MoneyItem movimentacoes)async{
    Database dbMovimentacoes = await db;
    return await dbMovimentacoes.delete(movimentacaoTABLE,
    where: "$idColumn =?",
    whereArgs: [movimentacoes.id]);
  }

  Future<int> updateMovimentacao(MoneyItem movimentacoes)async{
    print("chamada update");
    print(movimentacoes.toString());
    Database dbMovimentacoes = await db;
    return await dbMovimentacoes.update(movimentacaoTABLE,movimentacoes.toMap(),
    where: "$idColumn =?",
    whereArgs: [movimentacoes.id]
    );
  }

  Future<List> getAllMovimentacoes()async{
    Database dbMovimentacoes = await db;
    List listMap = await dbMovimentacoes.rawQuery("SELECT * FROM $movimentacaoTABLE");
    List<MoneyItem> listMovimentacoes = List();

    for(Map m in listMap){
      listMovimentacoes.add(MoneyItem.fromMap(m));
    }
    return listMovimentacoes;
  }
  Future<List> getAllMovimentacoesPorMes(String data)async{
    Database dbMovimentacoes = await db;
    List listMap = await dbMovimentacoes.rawQuery("SELECT * FROM $movimentacaoTABLE WHERE $dataColumn LIKE '%$data%'");
    List<MoneyItem> listMovimentacoes = List();

    for(Map m in listMap){
      listMovimentacoes.add(MoneyItem.fromMap(m));
    }
    return listMovimentacoes;
  }

  Future<List> getAllMovimentacoesPorTipo(String tipo)async{
    Database dbMovimentacoes = await db;
    List listMap = await dbMovimentacoes.rawQuery("SELECT * FROM $movimentacaoTABLE WHERE $tipoColumn ='$tipo' ");
    List<MoneyItem> listMovimentacoes = List();

    for(Map m in listMap){
      listMovimentacoes.add(MoneyItem.fromMap(m));
    }
    return listMovimentacoes;
  }

  

  Future<int> getNumber()async{
    Database dbMovimentacoes = await db;
    return Sqflite.firstIntValue(await dbMovimentacoes.rawQuery(
      "SELECT COUNT(*) FROM $movimentacaoTABLE"));
  }

  Future close()async{
    Database dbMovimentacoes = await db;
    dbMovimentacoes.close();
  }
}



class MoneyItem{

  int id;
  String data;
  double valor;
  String tipo;
  String descricao;

  MoneyItem();

  MoneyItem.fromMap(Map map){
    id = map[idColumn];
    valor = map[valorColumn];
    data = map[dataColumn];
    tipo = map[tipoColumn];
    descricao = map[descricaoColumn];
    
  }
 

  Map toMap(){
    Map<String,dynamic> map ={
      valorColumn :valor,
      dataColumn : data,
      tipoColumn : tipo,
      descricaoColumn : descricao,
      
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  String toString(){
    return "MoneyItem(id: $id, valor: $valor, data: $data, tipo: $tipo, desc: $descricao, )";
  }
}
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String moneyTABLE = "movimentacaoTABLE";
final String idColumn = "idColumn";
final String dateColumn = "dataColumn";
final String valueColumn = "valorColumn";
final String transactionTypeColumn = "tipoColumn";
final String moneyValueColumn = "descricaoColumn";

class MySqlDataBaseHelper {
  static final MySqlDataBaseHelper _instance = MySqlDataBaseHelper.internal();

  factory MySqlDataBaseHelper() => _instance;

  MySqlDataBaseHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "movimentacao.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE $moneyTABLE(" +
          "$idColumn INTEGER PRIMARY KEY," +
          "$valueColumn FLOAT," +
          "$dateColumn TEXT," +
          "$transactionTypeColumn TEXT," +
          "$moneyValueColumn TEXT)");
    });
  }

  Future<MoneyItem> saveMoneyItem(MoneyItem moneyItem) async {
    print("chamada save");
    Database myDb = await db;
    moneyItem.id = await myDb.insert(moneyTABLE, moneyItem.toMap());
    return moneyItem;
  }

  Future<MoneyItem> getMoneyItem(int id) async {
    Database dbMovimentacoes = await db;
    List<Map> maps = await dbMovimentacoes.query(moneyTABLE,
        columns: [
          idColumn,
          valueColumn,
          dateColumn,
          transactionTypeColumn,
          moneyValueColumn
        ],
        where: "$idColumn =?",
        whereArgs: [id]);

    if (maps.length > 0) {
      return MoneyItem.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteMoneyItem(MoneyItem movimentacoes) async {
    Database dbMovimentacoes = await db;
    return await dbMovimentacoes.delete(moneyTABLE,
        where: "$idColumn =?", whereArgs: [movimentacoes.id]);
  }

  Future<int> updateMoneyItem(MoneyItem moneyItem) async {
    print("update money item");
    print(moneyItem.toString());
    Database dbMoneyItem = await db;
    return await dbMoneyItem.update(moneyTABLE, moneyItem.toMap(),
        where: "$idColumn =?", whereArgs: [moneyItem.id]);
  }

  Future<List> getAllMoneyItem() async {
    Database dbMoneyItem = await db;
    List listMap = await dbMoneyItem.rawQuery("SELECT * FROM $moneyTABLE");
    List<MoneyItem> listMoneyItem = List();

    for (Map m in listMap) {
      listMoneyItem.add(MoneyItem.fromMap(m));
    }
    return listMoneyItem;
  }

  Future<List> getAllMoneyItems(String date) async {
    Database dbMoneyItem = await db;
    List listMap = await dbMoneyItem
        .rawQuery("SELECT * FROM $moneyTABLE WHERE $dateColumn LIKE '%$date%'");
    List<MoneyItem> listMoneyItem = List();

    for (Map m in listMap) {
      listMoneyItem.add(MoneyItem.fromMap(m));
    }
    return listMoneyItem;
  }

  Future<List> getAllMoneyItemByTransactionType(String tipo) async {
    Database dbMoneyItem = await db;
    List listMap = await dbMoneyItem.rawQuery(
        "SELECT * FROM $moneyTABLE WHERE $transactionTypeColumn ='$tipo' ");
    List<MoneyItem> listMoneyItem = List();

    for (Map m in listMap) {
      listMoneyItem.add(MoneyItem.fromMap(m));
    }
    return listMoneyItem;
  }

  Future<int> getNumber() async {
    Database myDb = await db;
    return Sqflite.firstIntValue(
        await myDb.rawQuery("SELECT COUNT(*) FROM $moneyTABLE"));
  }

  Future close() async {
    Database myDb = await db;
    myDb.close();
  }
}

class MoneyItem {
  int id;
  String date;
  double valor;
  String transactionType;
  String description;

  MoneyItem();

  MoneyItem.fromMap(Map map) {
    id = map[idColumn];
    valor = map[valueColumn];
    date = map[dateColumn];
    transactionType = map[transactionTypeColumn];
    description = map[moneyValueColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      valueColumn: valor,
      dateColumn: date,
      transactionTypeColumn: transactionType,
      moneyValueColumn: description,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  String toString() {
    return "MoneyItem(id: $id, valor: $valor, data: $date, tipo: $transactionType, desc: $description, )";
  }
}

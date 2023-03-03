import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const databaseName = "DatabaseContainer.db";
  static const databaseVersion = 1;

  static const tableName = "my_table";

  static const colId = '_id';
  static const colTitle = "title";
  static const colSubTitle = "subTitle";

  Database? _db;

  // this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, databaseName);

    _db = await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Craete SQL database
  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE $tableName (
        $colId INTEGER PRIMARY KEY,
        $colTitle TEXT NOT NULL,
        $colSubTitle TEXT NOT NULL
      )''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    return await _db!.insert(tableName, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final result = await _db?.query(tableName) ?? [];
    // ignore: unnecessary_null_comparison
    if (result == null) {
      return [];
    }
    return result;
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    final results = await _db!.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    int id = row[colId];
    return await _db!.update(
      tableName,
      row,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    return await _db!.delete(
      tableName,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }
}

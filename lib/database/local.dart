import 'package:mexanyd_desktop/database/interface.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabase extends IDatabase {
  static const version = 1;

  final String path;
  final Database _database;

  static Future<LocalDatabase> open() async {
    final dir = await getApplicationSupportDirectory();
    final dbPath = join(dir.path, "mexanyd.db");

    sqfliteFfiInit();

    final database = await databaseFactoryFfi.openDatabase(dbPath);

    await database.execute("PRAGMA foreign_keys = ON");

    await database.execute('''
      CREATE TABLE IF NOT EXISTS in_out (
        id INTEGER PRIMARY KEY,
        value REAL NOT NULL,
        creation TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        description TEXT NOT NULL DEFAULT '',
        type INTEGER NOT NULL DEFAULT 0
      )
    ''');

    return LocalDatabase._(dbPath, database);
  }

  LocalDatabase._(this.path, this._database);

  @override
  Future<void> deleteInOut(int id) async {
    await _database.delete("in_out", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<void> insertInOut(double value, InOutType type,
      {String description = ''}) async {
    await _database.insert("in_out", {
      "value": value,
      "description": description,
      "type": type.value,
    });
  }

  @override
  Future<List<InOut>> listInOut(
    int year,
    int month, {
    int? day,
    int limit = 50,
    int offset = 0,
    bool reversed = false,
  }) {
    final yearStr = year.toString().padLeft(4, '0');
    final monthStr = month.toString().padLeft(2, '0');
    final dayStr = day?.toString().padLeft(2, '0');

    var where = "strftime('%Y-%m', creation, 'localtime') = ?";
    var whereArgs = ["$yearStr-$monthStr"];
    if (dayStr != null) {
      where = "strftime('%Y-%m-%d', creation, 'localtime') = ?";
      whereArgs = ["$yearStr-$monthStr-$dayStr"];
    }

    final orderBy = reversed ? "creation DESC" : "creation ASC";

    return _database
        .query(
          "in_out",
          columns: [
            "id",
            "value",
            "datetime(creation, 'localtime') AS creation",
            "description",
            "type"
          ],
          where: where,
          whereArgs: whereArgs,
          orderBy: orderBy,
          limit: limit,
          offset: offset,
        )
        .then((rows) => rows
            .map((item) => InOut(
                  item['id'] as int,
                  item['value'] as double,
                  InOutType.fromValue(item['type'] as int),
                  description: item['description'] as String,
                  creation: DateTime.parse(item['creation'] as String),
                ))
            .toList());
  }

  @override
  Future<InOutStats> statsInOut(int year, int month, {int? day}) {
    final yearStr = year.toString().padLeft(4, '0');
    final monthStr = month.toString().padLeft(2, '0');
    final dayStr = day?.toString().padLeft(2, '0');

    var where = "strftime('%Y-%m', creation, 'localtime') = ?";
    var whereArgs = ["$yearStr-$monthStr"];
    if (dayStr != null) {
      where = "strftime('%Y-%m-%d', creation, 'localtime') = ?";
      whereArgs = ["$yearStr-$monthStr-$dayStr"];
    }

    return _database
        .query(
          "in_out",
          columns: ["COUNT(*)", "SUM(value)"],
          where: where,
          whereArgs: whereArgs,
        )
        .then((rows) => InOutStats(
              rows.first.values.first as int,
              (rows.first.values.last ?? 0.0) as double,
            ));
  }

  @override
  Future<int> countInOut(int year, int month, [int? day]) {
    final yearStr = year.toString().padLeft(4, '0');
    final monthStr = month.toString().padLeft(2, '0');
    final dayStr = day?.toString().padLeft(2, '0');

    var where = "strftime('%Y-%m', creation, 'localtime') = ?";
    var whereArgs = ["$yearStr-$monthStr"];
    if (dayStr != null) {
      where = "strftime('%Y-%m-%d', creation, 'localtime') = ?";
      whereArgs = ["$yearStr-$monthStr-$dayStr"];
    }

    return _database
        .query(
          "in_out",
          columns: ["COUNT(*)"],
          where: where,
          whereArgs: whereArgs,
        )
        .then((rows) => rows.first.values.first as int);
  }

  @override
  Future<double> totalInOut(int year, int month, {int? day, InOutType? type}) {
    final yearStr = year.toString().padLeft(4, '0');
    final monthStr = month.toString().padLeft(2, '0');
    final dayStr = day?.toString().padLeft(2, '0');

    var where = "strftime('%Y-%m', creation, 'localtime') = ?";
    var whereArgs = ["$yearStr-$monthStr"];
    if (dayStr != null) {
      if (type != null) {
        where = "strftime('%Y-%m-%d', creation, 'localtime') = ? AND type = ?";
        whereArgs = ["$yearStr-$monthStr-$dayStr", type.value.toString()];
      } else {
        where = "strftime('%Y-%m-%d', creation, 'localtime') = ?";
        whereArgs = ["$yearStr-$monthStr-$dayStr"];
      }
    } else if (type != null) {
      where = "strftime('%Y-%m', creation, 'localtime') = ? AND type = ?";
      whereArgs = ["$yearStr-$monthStr", type.value.toString()];
    }

    return _database
        .query(
          "in_out",
          columns: ["SUM(value)"],
          where: where,
          whereArgs: whereArgs,
        )
        .then((rows) => (rows.first.values.first ?? 0.0) as double);
  }

  @override
  Future<Map<int, InOutDayTotal>> totalInOutByDay(int year, int month) {
    final yearStr = year.toString().padLeft(4, '0');
    final monthStr = month.toString().padLeft(2, '0');

    return _database
        .query(
          "in_out",
          columns: [
            "strftime('%d', creation, 'localtime') AS day",
            "SUM(value) AS total",
            "SUM(CASE WHEN type = 0 THEN value ELSE 0 END) AS money",
            "SUM(CASE WHEN type = 1 THEN value ELSE 0 END) AS credit",
            "SUM(CASE WHEN type = 2 THEN value ELSE 0 END) AS future",
          ],
          where: "strftime('%Y-%m', creation, 'localtime') = ?",
          whereArgs: ["$yearStr-$monthStr"],
          groupBy: "day",
        )
        .then((rows) => rows.fold<Map<int, InOutDayTotal>>({}, (map, item) {
              final day = int.parse(item['day'] as String);
              map[day] = InOutDayTotal(
                _getDouble(item['total']),
                _getDouble(item['money']),
                _getDouble(item['credit']),
                _getDouble(item['future']),
              );
              return map;
            }));
  }

  double _getDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      throw ArgumentError('Invalid value: $value');
    }
  }
}

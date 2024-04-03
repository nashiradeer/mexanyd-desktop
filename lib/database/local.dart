import 'dart:io';

import 'package:mexanyd_desktop/database/interface.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabase extends IDatabase {
  final String path;
  final Database _database;

  static Future<LocalDatabase> open() async {
    var baseDir = Platform.environment['APPDATA'] ?? "C:\\ProgramData";
    var dataDir = Directory(join(baseDir, "Mexanyd Desktop"));
    await dataDir.create(recursive: true);

    var path = join(dataDir.path, "mexanyd.db");
    sqfliteFfiInit();
    var database = await databaseFactoryFfi.openDatabase(path);

    await database.execute("PRAGMA foreign_keys = ON");

    await database.execute('''
      CREATE TABLE IF NOT EXISTS in_out (
        id INTEGER PRIMARY KEY,
        value REAL NOT NULL,
        creation TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    return LocalDatabase._(path, database);
  }

  LocalDatabase._(this.path, this._database);

  @override
  Future<void> deleteInOut(int id) async {
    await _database.delete("in_out", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<InOut?> getInOut(int id) async {
    var result = await _database.query(
      "in_out",
      columns: ["id", "value", "creation", "description"],
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return InOut.fromMap(result.first);
  }

  @override
  Future<void> insertInOut(double value, {String description = ''}) async {
    await _database.insert("in_out", {
      "creation": DateTime.timestamp().toDateString(),
      "value": value,
      "description": description,
    });
  }

  @override
  Future<List<InOut>> listInOutByCreation(int year,
      {int? month, int? day, int limit = 10, int offset = 0}) async {
    var yearStr = year.toString().padLeft(4, '0');
    var whereArg = "$yearStr%";

    if (month != null) {
      var monthStr = month.toString().padLeft(2, '0');

      if (day != null) {
        var dayStr = day.toString().padLeft(2, '0');
        whereArg = "$yearStr-$monthStr-$dayStr";
      } else {
        whereArg = "$yearStr-$monthStr%";
      }
    }

    return await _database
        .query("in_out",
            columns: ["id", "value", "creation", "description"],
            limit: limit,
            offset: offset,
            where: "creation LIKE ?",
            whereArgs: [whereArg])
        .then((value) => value.map((e) => InOut.fromMap(e)).toList());
  }
}

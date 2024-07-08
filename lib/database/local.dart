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

    await database.execute('''
      CREATE TABLE IF NOT EXISTS vehicle (
        id INTEGER PRIMARY KEY,
        brand TEXT NOT NULL DEFAULT '',
        model TEXT NOT NULL DEFAULT '',
        variant TEXT NOT NULL DEFAULT '',
        creation TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await database.execute('''
      CREATE TABLE IF NOT EXISTS car_service (
        id INTEGER PRIMARY KEY,
        vehicle_id INTEGER NOT NULL,
        plate TEXT NOT NULL DEFAULT '',
        color TEXT NOT NULL DEFAULT '',
        odometer INTEGER NOT NULL DEFAULT 0,
        owner TEXT NOT NULL DEFAULT '',
        service TEXT NOT NULL DEFAULT '',
        value REAL NOT NULL DEFAULT 0,
        commission REAL NOT NULL DEFAULT 0,
        creation TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE RESTRICT ON UPDATE CASCADE
      )
    ''');

    await database.execute('''
      CREATE TABLE IF NOT EXISTS service_item (
        id INTEGER PRIMARY KEY,
        service_id INTEGER NOT NULL,
        bought INTEGER NOT NULL,
        name TEXT NOT NULL DEFAULT '',
        price REAL NOT NULL DEFAULT 0,
        creation TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (service_id) REFERENCES car_service (id) ON DELETE CASCADE ON UPDATE CASCADE
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

  @override
  Future<void> insertVehicle(String brand, String model, String variant) async {
    await _database.insert("vehicle", {
      "brand": brand,
      "model": model,
      "variant": variant,
    });
  }

  @override
  Future<void> deleteVehicle(int id) async {
    await _database.delete("vehicle", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<Vehicle>> listVehicle({
    String? brand,
    String? model,
    String? variant,
    int limit = 50,
    int offset = 0,
  }) {
    return _database
        .query(
          "vehicle",
          columns: ["id", "brand", "model", "variant", "creation"],
          limit: limit,
          offset: offset,
          orderBy: "creation DESC",
          where: [
            if (brand != null) "brand LIKE ? COLLATE NOCASE",
            if (model != null) "model LIKE ? COLLATE NOCASE",
            if (variant != null) "variant LIKE ? COLLATE NOCASE",
          ].join(" AND "),
          whereArgs: [
            if (brand != null) '%$brand%',
            if (model != null) '%$model%',
            if (variant != null) '%$variant%',
          ],
        )
        .then((rows) => rows
            .map((item) => Vehicle(
                  item['id'] as int,
                  item['brand'] as String,
                  item['model'] as String,
                  item['variant'] as String,
                  creation: DateTime.parse(item['creation'] as String),
                ))
            .toList());
  }

  @override
  Future<int> countVehicle() {
    return _database.query(
      "vehicle",
      columns: ["COUNT(*)"],
    ).then((rows) => rows.first.values.first as int);
  }

  @override
  Future<CarService> createCarService({
    required int vehicleId,
    required String plate,
    required String color,
    required int odometer,
    required String owner,
    required String service,
    required double value,
    required double commission,
  }) {
    return _database.transaction((txn) async {
      final id = await txn.insert("car_service", {
        "vehicle_id": vehicleId,
        "plate": plate,
        "color": color,
        "odometer": odometer,
        "owner": owner,
        "service": service,
        "value": value,
        "commission": commission,
      });

      final creation = await txn.query(
        "car_service",
        columns: ["creation"],
        where: "id = ?",
        whereArgs: [id],
      );

      return CarService(
        id: id,
        vehicleId: vehicleId,
        plate: plate,
        color: color,
        odometer: odometer,
        owner: owner,
        service: service,
        value: value,
        commission: commission,
        creation: DateTime.parse(creation.first['creation'] as String),
      );
    });
  }

  @override
  Future<void> deleteCarService(int id) async {
    await _database.delete("car_service", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<CarService>> listCarService(
      {int? vehicleId,
      String? plate,
      String? owner,
      int limit = 50,
      int offset = 0}) {
    return _database
        .query(
          "car_service",
          columns: [
            "id",
            "vehicle_id",
            "plate",
            "color",
            "odometer",
            "owner",
            "service",
            "value",
            "creation"
          ],
          limit: limit,
          offset: offset,
          orderBy: "creation DESC",
          where: [
            if (vehicleId != null) "vehicle_id = ?",
            if (plate != null) "plate LIKE ? COLLATE NOCASE",
            if (owner != null) "owner LIKE ? COLLATE NOCASE",
          ].join(" AND "),
          whereArgs: [
            if (vehicleId != null) vehicleId,
            if (plate != null) '%$plate%',
            if (owner != null) '%$owner%',
          ],
        )
        .then((rows) => rows
            .map((item) => CarService(
                  id: item['id'] as int,
                  vehicleId: item['vehicle_id'] as int,
                  plate: item['plate'] as String,
                  color: item['color'] as String,
                  odometer: item['odometer'] as int,
                  owner: item['owner'] as String,
                  service: item['service'] as String,
                  value: item['value'] as double,
                  commission: item['commission'] as double,
                  creation: DateTime.parse(item['creation'] as String),
                ))
            .toList());
  }

  @override
  Future<int> countCarService({int? vehicleId, String? plate, String? owner}) {
    return _database
        .query(
          "car_service",
          columns: ["COUNT(*)"],
          where: [
            if (vehicleId != null) "vehicle_id = ?",
            if (plate != null) "plate LIKE ? COLLATE NOCASE",
            if (owner != null) "owner LIKE ? COLLATE NOCASE",
          ].join(" AND "),
          whereArgs: [
            if (vehicleId != null) vehicleId,
            if (plate != null) '%$plate%',
            if (owner != null) '%$owner%',
          ],
        )
        .then((rows) => rows.first.values.first as int);
  }

  @override
  Future<bool> hasServiceWithVehicle(int vehicleId) {
    return _database
        .query(
          "car_service",
          columns: ["COUNT(*)"],
          where: "vehicle_id = ?",
          whereArgs: [vehicleId],
          limit: 1,
        )
        .then((rows) => rows.first.values.first as int > 0);
  }

  @override
  Future<void> bulkInsertServiceItem(
      int serviceId, List<BulkServiceItem> items) {
    return _database.transaction((txn) async {
      for (final item in items) {
        await txn.insert("service_item", {
          "service_id": serviceId,
          "bought": item.bought ? 1 : 0,
          "name": item.name,
          "price": item.price,
        });
      }
    });
  }

  @override
  Future<void> deleteServiceItem(int id) {
    return _database.delete("service_item", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<ServiceItem>> listServiceItem(int serviceId,
      {bool? bought, int limit = 50, int offset = 0}) {
    return _database
        .query(
          "service_item",
          columns: ["id", "service_id", "bought", "name", "price", "creation"],
          limit: limit,
          offset: offset,
          orderBy: "creation DESC",
          where: [
            "service_id = ?",
            if (bought != null) "bought = ?",
          ].join(" AND "),
          whereArgs: [
            serviceId,
            if (bought != null) bought ? 1 : 0,
          ],
        )
        .then((rows) => rows
            .map((item) => ServiceItem(
                  item['id'] as int,
                  item['service_id'] as int,
                  item['bought'] as int == 1,
                  item['name'] as String,
                  item['price'] as double,
                  creation: DateTime.parse(item['creation'] as String),
                ))
            .toList());
  }

  @override
  Future<int> countServiceItem(int serviceId, {bool? bought}) {
    return _database
        .query(
          "service_item",
          columns: ["COUNT(*)"],
          where: [
            "service_id = ?",
            if (bought != null) "bought = ?",
          ].join(" AND "),
          whereArgs: [
            serviceId,
            if (bought != null) bought ? 1 : 0,
          ],
        )
        .then((rows) => rows.first.values.first as int);
  }

  @override
  Future<double> totalServiceItem(int serviceId, {bool? bought}) {
    return _database
        .query(
          "service_item",
          columns: ["SUM(price)"],
          where: [
            "service_id = ?",
            if (bought != null) "bought = ?",
          ].join(" AND "),
          whereArgs: [
            serviceId,
            if (bought != null) bought ? 1 : 0,
          ],
        )
        .then((rows) => (rows.first.values.first ?? 0.0) as double);
  }

  @override
  Future<ServiceItemStats> statsServiceItem(int serviceId, {bool? bought}) {
    return _database
        .query(
          "service_item",
          columns: ["COUNT(*)", "SUM(price)"],
          where: [
            "service_id = ?",
            if (bought != null) "bought = ?",
          ].join(" AND "),
          whereArgs: [
            serviceId,
            if (bought != null) bought ? 1 : 0,
          ],
        )
        .then((rows) => ServiceItemStats(
              rows.first.values.first as int,
              (rows.first.values.last ?? 0.0) as double,
            ));
  }

  /// Checks if the value is an integer or a double and returns a double.
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

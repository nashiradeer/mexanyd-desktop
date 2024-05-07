/// Global database instance to be used by the application.
late IDatabase globalDatabase;

/// Interface for the database drivers.
abstract class IDatabase {
  /// Inserts a new in/out with the given [value], [type] and [description].
  Future<void> insertInOut(double value, InOutType type,
      {String description = ''});

  /// Deletes the in/out with the given [id].
  Future<void> deleteInOut(int id);

  /// Lists the in/outs created in the given creation date.
  Future<List<InOut>> listInOut(
    int year,
    int month, {
    int? day,
    int limit = 50,
    int offset = 0,
    bool reversed = false,
  });

  /// Gets the statistics of in/outs.
  Future<InOutStats> statsInOut(int year, int month, {int? day});

  /// Gets the total count of in/outs.
  Future<int> countInOut(int year, int month, [int? day]);

  /// Gets the total value of in/outs.
  Future<double> totalInOut(int year, int month, {int? day, InOutType? type});

  /// Gets the total value of in/outs by day.
  Future<Map<int, InOutDayTotal>> totalInOutByDay(int year, int month);

  /// Inserts a new vehicle with the given [brand], [model] and [motor].
  Future<void> insertVehicle(String brand, String model, String motor);

  /// Deletes the vehicle with the given [id].
  Future<void> deleteVehicle(int id);

  /// Lists the vehicles.
  Future<List<Vehicle>> listVehicle({int limit = 50, int offset = 0});

  /// Gets the total count of vehicles.
  Future<int> countVehicle();
}

/// Represents the statistics of in/outs.
class InOutStats {
  /// The total count of in/outs.
  final int count;

  /// The total value of in/outs.
  final double total;

  /// Creates a new in/out statistics.
  const InOutStats(this.count, this.total);
}

/// Represents the sum of all values of in/outs.
class InOutDayTotal {
  /// The total value of in/outs.
  final double total;

  /// The total value of money in/outs.
  final double money;

  /// The total value of credit in/outs.
  final double credit;

  /// The total value of future in/outs.
  final double future;

  /// Creates a new [InOutDayTotal].
  const InOutDayTotal(this.total, this.money, this.credit, this.future);
}

/// Represents the types that an in/out can have.
enum InOutType {
  /// Represents a money in/out.
  money,

  /// Represents a credit in/out.
  credit,

  /// Represents a future in/out.
  future;

  /// Gets the value of the in/out type.
  int get value {
    switch (this) {
      case InOutType.money:
        return 0;
      case InOutType.credit:
        return 1;
      case InOutType.future:
        return 2;
    }
  }

  /// Creates an in/out type from the given [value].
  static InOutType fromValue(int value) {
    switch (value) {
      case 0:
        return InOutType.money;
      case 1:
        return InOutType.credit;
      case 2:
        return InOutType.future;
      default:
        throw ArgumentError('Invalid value: $value');
    }
  }
}

/// Represents an input or output.
class InOut {
  /// The unique identifier of the in/out.
  final int id;

  /// The value of the in/out.
  final double value;

  /// The creation date of the in/out.
  final DateTime creation;

  /// The description of the in/out.
  final String description;

  /// The type of the in/out.
  final InOutType type;

  /// Creates a new in/out.
  InOut(this.id, this.value, this.type,
      {DateTime? creation, this.description = ''})
      : creation = creation ?? DateTime.now();
}

/// Represents a vehicle.
class Vehicle {
  /// The unique identifier of the vehicle.
  final int id;
  // The brand of the vehicle.
  final String brand;
  // The model of the vehicle.
  final String model;
  // The motor of the vehicle.
  final String motor;
  // The creation date of this database entry.
  final DateTime creation;

  /// Creates a new vehicle.
  Vehicle(this.id, this.brand, this.model, this.motor, {DateTime? creation})
      : creation = creation ?? DateTime.now();
}

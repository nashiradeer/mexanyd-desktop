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

  /// Inserts a new vehicle with the given [brand], [model] and [variant].
  Future<void> insertVehicle(String brand, String model, String variant);

  /// Deletes the vehicle with the given [id].
  Future<void> deleteVehicle(int id);

  /// Lists the vehicles.
  Future<List<Vehicle>> listVehicle({
    String? brand,
    String? model,
    String? variant,
    int limit = 50,
    int offset = 0,
  });

  /// Gets the total count of vehicles.
  Future<int> countVehicle();

  /// Inserts a new car service with the given [vehicleId], [plate], [color], [odometer], [owner], [service] and [value], returning the created [CarService].
  Future<CarService> createCarService({
    required int vehicleId,
    required String plate,
    required String color,
    required int odometer,
    required String owner,
    required String service,
    required double value,
    required double commission,
  });

  /// Checks if a vehicle has a service.
  Future<bool> hasServiceWithVehicle(int vehicleId);

  /// Deletes the car service with the given [id].
  Future<void> deleteCarService(int id);

  /// Lists the car services.
  Future<List<CarService>> listCarService({
    int? vehicleId,
    String? plate,
    String? owner,
    int limit = 50,
    int offset = 0,
  });

  /// Gets the total count of car services.
  Future<int> countCarService({int? vehicleId, String? plate, String? owner});

  /// Bulk inserts a list of items used in a service with the given [serviceId].
  Future<void> bulkInsertServiceItem(
      int serviceId, List<BulkServiceItem> items);

  /// Deletes a item from a service with the given [id].
  Future<void> deleteServiceItem(int id);

  /// Lists the items used in a service.
  Future<List<ServiceItem>> listServiceItem(
    int serviceId, {
    bool? bought,
    int limit = 50,
    int offset = 0,
  });

  /// Gets the total count of items used in a service.
  Future<int> countServiceItem(int serviceId, {bool? bought});

  /// Gets the total value of items used in a service.
  Future<double> totalServiceItem(int serviceId, {bool? bought});

  /// Gets the statistics of the items used in a service.
  Future<ServiceItemStats> statsServiceItem(int serviceId, {bool? bought});
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

  /// The brand of the vehicle.
  final String brand;

  /// The model of the vehicle.
  final String model;

  /// The variant of the vehicle.
  final String variant;

  /// The creation date of this database entry.
  final DateTime creation;

  /// Creates a new vehicle.
  Vehicle(this.id, this.brand, this.model, this.variant, {DateTime? creation})
      : creation = creation ?? DateTime.now();
}

/// Represents a car service.
class CarService {
  /// The unique identifier of the car service.
  final int id;

  /// The vehicle identifier of the car service.
  final int vehicleId;

  /// The plate of the vehicle.
  final String plate;

  /// The color of the vehicle.
  final String color;

  /// The odometer value of the vehicle.
  final int odometer;

  /// The owner's name of the vehicle.
  final String owner;

  /// The service made to the vehicle.
  final String service;

  /// The value earned in the service.
  final double value;

  /// The commission earned in the service.
  final double commission;

  /// The creation date of this database entry.
  final DateTime creation;

  /// Creates a new car service.
  CarService({
    required this.id,
    required this.vehicleId,
    required this.plate,
    required this.color,
    required this.odometer,
    required this.owner,
    required this.service,
    required this.value,
    required this.commission,
    DateTime? creation,
  }) : creation = creation ?? DateTime.now();
}

/// Represents a item used in a car service.
class ServiceItem {
  /// The unique identifier of the service item.
  final int id;

  /// The service identifier associated with this item.
  final int serviceId;

  /// The item was bought from other place.
  final bool bought;

  /// The name of the item.
  final String name;

  /// The price of the item.
  final double price;

  /// The creation date of this database entry.
  final DateTime creation;

  /// Creates a new service item.
  ServiceItem(this.id, this.serviceId, this.bought, this.name, this.price,
      {DateTime? creation})
      : creation = creation ?? DateTime.now();
}

/// Single item to be used in bulk insert.
class BulkServiceItem {
  /// The item was bought from other place.
  final bool bought;

  /// The name of the item.
  final String name;

  /// The price of the item.
  final double price;

  /// Creates a new bulk service item.
  const BulkServiceItem(this.bought, this.name, this.price);
}

/// Represents the statistics of a service item.
class ServiceItemStats {
  /// The total count of the service items.
  final int count;

  /// The total value of the service items.
  final double total;

  /// Creates a new service item statistics.
  const ServiceItemStats(this.count, this.total);
}

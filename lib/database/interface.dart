late IDatabase globalDatabase;

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

  /// Gets the total count of in/outs.
  Future<int> countInOut(int year, int month, [int? day]);

  /// Gets the total value of in/outs.
  Future<double> totalInOut(int year, int month, [int? day]);
}

enum InOutType {
  money,
  credit,
  future;

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
  static const int moneyType = 0;
  static const int creditType = 1;
  static const int futureType = 2;

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

  InOut(this.id, this.value, this.type,
      {DateTime? creation, this.description = ''})
      : creation = creation ?? DateTime.now();

  /// Creates an [InOut] from a map.
  factory InOut.fromMap(Map<String, Object?> map) {
    return InOut(
      map['id'] as int,
      map['value'] as double,
      InOutType.fromValue(map['type'] as int),
      creation: DateTime.parse(map['creation'] as String),
      description: map['description'] as String,
    );
  }

  /// Converts the [InOut] to a map.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'value': value,
      'type': type.value,
      'creation': creation.toIso8601String(),
      'description': description,
    };
  }
}

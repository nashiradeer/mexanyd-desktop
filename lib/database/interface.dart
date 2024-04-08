late IDatabase globalDatabase;

abstract class IDatabase {
  /// Inserts a new in/out with the given [value] and [description].
  Future<void> insertInOut(double value, {String description = ''});

  /// Deletes the in/out with the given [id].
  Future<void> deleteInOut(int id);

  /// Gets the in/out with the given [id].
  Future<InOut?> getInOut(int id);

  /// Lists the in/outs created in the given creation date.
  Future<List<InOut>> listInOutByCreation(int year,
      {int? month,
      int? day,
      int limit = 10,
      int offset = 0,
      bool reversed = false});
}

extension Date on DateTime {
  /// Returns a string in the format 'yyyy-MM-dd'.
  String toDateString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
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

  InOut(this.id, this.value, {DateTime? creation, this.description = ''})
      : creation = creation ?? DateTime.now();

  /// Creates an [InOut] from a map.
  factory InOut.fromMap(Map<String, Object?> map) {
    return InOut(
      map['id'] as int,
      map['value'] as double,
      creation: DateTime.parse(map['creation'] as String),
      description: map['description'] as String,
    );
  }

  /// Converts the [InOut] to a map.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'value': value,
      'creation': creation.toDateString(),
      'description': description,
    };
  }
}

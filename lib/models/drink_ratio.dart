/// A sugared/caffeinated drink that requires water compensation.
class DrinkType {
  final String id;
  final String name;
  final String emoji;
  final int volumeMl; // typical can/bottle size
  final double waterRatio; // how many ml of water per ml of drink

  const DrinkType({
    required this.id,
    required this.name,
    required this.emoji,
    required this.volumeMl,
    required this.waterRatio,
  });

  /// Required water compensation in ml for one unit of this drink.
  int get requiredWaterMl => (volumeMl * waterRatio).round();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'volumeMl': volumeMl,
        'waterRatio': waterRatio,
      };

  factory DrinkType.fromJson(Map<String, dynamic> json) => DrinkType(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        volumeMl: json['volumeMl'] as int,
        waterRatio: (json['waterRatio'] as num).toDouble(),
      );
}

  /// Preset drink types with ratios from our research.
  class DrinkPresets {
    static const List<DrinkType> all = [
      DrinkType(id: 'coca', name: 'Coca-Cola', emoji: '', volumeMl: 330, waterRatio: 2.0),
      DrinkType(id: 'holy', name: 'Holy', emoji: '', volumeMl: 330, waterRatio: 3.0),
      DrinkType(id: 'redbull', name: 'Red Bull', emoji: '', volumeMl: 250, waterRatio: 3.0),
      DrinkType(id: 'coffee', name: 'Coffee', emoji: '', volumeMl: 120, waterRatio: 2.5),
      DrinkType(id: 'tea', name: 'Tea', emoji: '', volumeMl: 250, waterRatio: 1.5),
      DrinkType(id: 'juice', name: 'Juice', emoji: '', volumeMl: 250, waterRatio: 1.0),
      DrinkType(id: 'beer', name: 'Beer', emoji: '', volumeMl: 330, waterRatio: 2.0),
    ];

  static DrinkType? byId(String id) {
    for (final d in all) {
      if (d.id == id) return d;
    }
    return null;
  }
}

/// A logged sugary/caffeinated drink entry (triggers water debt).
class DrinkLog {
  final String id;
  final DateTime timestamp;
  final String drinkTypeId;
  final int volumeMl;
  final double waterRatio;
  final bool compensated; // has the user drunk the required water?

  DrinkLog({
    required this.id,
    required this.timestamp,
    required this.drinkTypeId,
    required this.volumeMl,
    required this.waterRatio,
    this.compensated = false,
  });

  int get requiredWaterMl => (volumeMl * waterRatio).round();

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'drinkTypeId': drinkTypeId,
        'volumeMl': volumeMl,
        'waterRatio': waterRatio,
        'compensated': compensated,
      };

  factory DrinkLog.fromJson(Map<String, dynamic> json) => DrinkLog(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        drinkTypeId: json['drinkTypeId'] as String,
        volumeMl: json['volumeMl'] as int,
        waterRatio: (json['waterRatio'] as num).toDouble(),
        compensated: json['compensated'] as bool? ?? false,
      );
}
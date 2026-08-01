/// A single water intake log entry.
class WaterLog {
  final String id;
  final DateTime timestamp;
  final int amountMl; // water in milliliters
  final LogSource source; // tap, widget, reminder

  WaterLog({
    required this.id,
    required this.timestamp,
    required this.amountMl,
    this.source = LogSource.tap,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'amountMl': amountMl,
        'source': source.name,
      };

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        amountMl: json['amountMl'] as int,
        source: LogSource.values.byName(json['source'] as String? ?? 'tap'),
      );
}

enum LogSource { tap, widget, reminder }
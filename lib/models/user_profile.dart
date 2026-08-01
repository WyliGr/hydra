/// User profile for auto-calculating daily water goal.
class UserProfile {
  final int weightKg; // body weight
  final int wakeHour; // typical wake time (24h)
  final int sleepHour; // typical sleep time (24h)
  final bool autoGoal; // auto-calculate goal from weight

  const UserProfile({
    this.weightKg = 70,
    this.wakeHour = 7,
    this.sleepHour = 23,
    this.autoGoal = true,
  });

  /// Standard formula: 35ml per kg of body weight.
  int get recommendedDailyMl => (weightKg * 35).round();

  UserProfile copyWith({
    int? weightKg,
    int? wakeHour,
    int? sleepHour,
    bool? autoGoal,
  }) =>
      UserProfile(
        weightKg: weightKg ?? this.weightKg,
        wakeHour: wakeHour ?? this.wakeHour,
        sleepHour: sleepHour ?? this.sleepHour,
        autoGoal: autoGoal ?? this.autoGoal,
      );

  Map<String, dynamic> toJson() => {
        'weightKg': weightKg,
        'wakeHour': wakeHour,
        'sleepHour': sleepHour,
        'autoGoal': autoGoal,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        weightKg: json['weightKg'] as int? ?? 70,
        wakeHour: json['wakeHour'] as int? ?? 7,
        sleepHour: json['sleepHour'] as int? ?? 23,
        autoGoal: json['autoGoal'] as bool? ?? true,
      );
}
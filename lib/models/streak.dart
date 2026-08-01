/// Tracks consecutive days where the daily water goal was met,
/// plus the longest such run and the recent goal-hit history.
class Streak {
  final int currentStreak;
  final int longestStreak;
  final List<bool> history;

  const Streak({
    required this.currentStreak,
    required this.longestStreak,
    required this.history,
  });

  static const empty = Streak(
    currentStreak: 0,
    longestStreak: 0,
    history: <bool>[],
  );

  Streak copyWith({
    int? currentStreak,
    int? longestStreak,
    List<bool>? history,
  }) =>
      Streak(
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        history: history ?? this.history,
      );
}

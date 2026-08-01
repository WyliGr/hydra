/// Utility for formatting milliliters into human-readable strings.
class FormatUtil {
  static String ml(int ml) {
    if (ml >= 1000) {
      final l = ml / 1000;
      return '${l.toStringAsFixed(l == l.roundToDouble() ? 0 : 1)}L';
    }
    return '${ml}ml';
  }

  static String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays}j';
  }

  static String dayLabel(DateTime date) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[date.weekday - 1];
  }
}
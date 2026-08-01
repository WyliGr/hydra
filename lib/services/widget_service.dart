import 'package:home_widget/home_widget.dart';

/// Handles pushing data to the platform homescreen widget.
class WidgetService {
  static const _appGroupId = 'group.com.wyligr.hydra';
  static const _androidProviderName = 'com.wyligr.hydra.HydraWidgetProvider';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Push current hydration data to the widget.
  static Future<void> updateWidget({
    required int todayMl,
    required int goalMl,
    required int debtMl,
  }) async {
    await HomeWidget.saveWidgetData('today_ml', todayMl);
    await HomeWidget.saveWidgetData('goal_ml', goalMl);
    await HomeWidget.saveWidgetData('debt_ml', debtMl);
    await HomeWidget.saveWidgetData('progress', (todayMl / (goalMl + debtMl)).clamp(0.0, 1.0));
    await HomeWidget.updateWidget(
      androidName: _androidProviderName,
      iOSName: 'HydraWidget',
    );
  }
}
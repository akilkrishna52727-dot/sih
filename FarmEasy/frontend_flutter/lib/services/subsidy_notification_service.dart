import 'notification_service.dart';
import 'subsidy_service.dart';

class SubsidyNotificationService {
  static Future<void> checkNewSchemes() async {
    // In a real app, fetch from backend or remote config.
    final schemes = SubsidyService.getSubsidySchemes();
    // Demo: notify if at least one active scheme exists
    final activeCount = schemes.where((s) => s.isActive).length;
    if (activeCount > 0) {
      await NotificationService().showSubsidyUpdate(
        'New Subsidy Schemes Available!',
        'Check out $activeCount government schemes for farmers',
      );
    }
  }
}

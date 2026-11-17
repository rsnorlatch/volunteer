enum NotificationType { reminder, registration }

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isNew = true,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  bool isNew;
}

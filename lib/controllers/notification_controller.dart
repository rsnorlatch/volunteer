import 'package:get/get.dart';

import 'package:volunteer/data/models/app_notification.dart';

enum NotificationFilter { all, reminder, registration }

class NotificationController extends GetxController {
  final items = <AppNotification>[].obs;
  final filter = NotificationFilter.all.obs;
  final reminderOn = true.obs;

  @override
  void onInit() {
    super.onInit();
    items.assignAll([
      AppNotification(
        id: 'n1',
        title: 'Pengingat kegiatan donor',
        body: 'Besok, 09.00 • PMI Kota Bandung',
        type: NotificationType.reminder,
      ),
      AppNotification(
        id: 'n2',
        title: 'Pendaftaran diterima',
        body: 'Kegiatan Donor Darah Peduli Sesama',
        type: NotificationType.registration,
      ),
      AppNotification(
        id: 'n3',
        title: 'Jadwal donor mendatang',
        body: 'Kegiatan dimulai dalam 3 hari',
        type: NotificationType.reminder,
      ),
      AppNotification(
        id: 'n4',
        title: 'Perubahan kegiatan',
        body: 'Penyelenggara memperbarui informasi',
        type: NotificationType.reminder,
      ),
    ]);
  }

  List<AppNotification> get visible {
    switch (filter.value) {
      case NotificationFilter.all:
        return items.toList();
      case NotificationFilter.reminder:
        return items.where((n) => n.type == NotificationType.reminder).toList();
      case NotificationFilter.registration:
        return items
            .where((n) => n.type == NotificationType.registration)
            .toList();
    }
  }

  int get unreadCount => items.where((n) => n.isNew).length;

  void markRead(String id) {
    final i = items.indexWhere((n) => n.id == id);
    if (i >= 0) {
      items[i].isNew = false;
      items.refresh();
    }
  }

  void add(String title, String body, NotificationType type) {
    items.insert(
      0,
      AppNotification(
        id: 'n-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        body: body,
        type: type,
      ),
    );
  }
}

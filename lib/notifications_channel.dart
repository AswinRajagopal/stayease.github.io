import 'package:awesome_notifications/awesome_notifications.dart';



Future createTenantNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id:1,
      channelKey: 'basic_channel',
      title:
      '${Emojis.household_bed + Emojis.smile_smiling_face_with_halo} Tenant Added!!!',
      body: 'A room is filled',
      notificationLayout: NotificationLayout.BigPicture,
    ),
  );
}

Future removeTenantNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id:2,
      channelKey: 'basic_channel',
      title:
      '${Emojis.household_bed + Emojis.smile_sad_but_relieved_face} Tenant Removed!!!',
      body: 'A room is Empty',
      notificationLayout: NotificationLayout.BigPicture,
    ),
  );
}
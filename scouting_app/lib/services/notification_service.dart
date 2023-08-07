import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/res_icon',
      [
        NotificationChannel(
          channelKey: 'high_importance_channel',
          channelName: 'High Importance Notifications',
          channelDescription: 'Notification channel for high importance events',
          defaultColor: Colors.orange.shade600,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          onlyAlertOnce: true,
          enableLights: true,
          soundSource: "resource://raw/res_notification_sound",
          playSound: true,
        ),
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((value) => {
          if (!value)
            {AwesomeNotifications().requestPermissionToSendNotifications()}
        });

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    );
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    log(receivedAction.toString());
    final payload = receivedAction.payload ?? {};
    log(payload.toString());
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    log(receivedAction.toString());
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    log(receivedNotification.toString());
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    log(receivedNotification.toString());
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? notificationCategory,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final NotificationCalendar? schedule,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && schedule != null));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        customSound: "resource://raw/res_notification_sound",
        id: -1,
        channelKey: 'high_importance_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: notificationCategory,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule: scheduled ? schedule : null,
    );
  }

  static void clearNotifications() {
    AwesomeNotifications().cancelAll();
  }
}

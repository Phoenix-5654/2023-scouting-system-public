import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:scouting_demo/services/googleSheetsAPI.dart';
import 'package:scouting_demo/widgets/userManager.dart';

import '../widgets/globalDataManager.dart';

class ScheduleData {
  void getSchedule(var schedule) async {
    // Get the schedule from the database google sheets
    log("Getting schedule", name: "ScheduleData", time: DateTime.now());
    var eventKey = ValueNotifier('cmptx');
    GlobalDataManager.getEventKeyNotifier(eventKey);
    var title = "${eventKey.value.toUpperCase()}_Schedule";

    List<Map<String, String>> data = [];
    var testCount = 0;

    while (true) {
      try {
        data = (await GoogleSheetsAPI().getMap(title: title))!;
        break;
      } catch (e) {
        if (testCount > 5) {
          break;
        }
        log(e.toString());
        await Future.delayed(const Duration(minutes: 1));
        testCount += 1;
      }
    }
    var userMail = UserManager().user!.email;

    Map<String, List<dynamic>> finalData = {};

    // Iterate through the data and add the relevant data to the schedule map
    // relevant data is the matches where the mail of the user is in

    log("Looking for user: $userMail", name: "ScheduleData");
    checkSchedule(data, userMail, finalData);
    log("Schedule: $finalData", name: "ScheduleData");

    // Add listener to the event key notifier
    eventKey.addListener(() async {
      if (eventKey.value != '') {
        log("Key changed to: ${eventKey.value}", name: "ScheduleData");
        var title = "${eventKey.value.toUpperCase()}_Schedule";
        final data = await GoogleSheetsAPI().getMap(title: title);
        checkSchedule(data!, userMail, finalData);
      }
    });

    schedule.value = finalData;
  }

  void checkSchedule(List<Map<String, String>> data, String? userMail,
      Map<String, List<dynamic>> finalData) async {
    for (var entry in data) {
      // If user's mail in entry - log it
      if (entry.containsValue(userMail)) {
        // Extract the number from the string: "<type> <number>"
        var matchNumber = entry.values.elementAt(1);

        // Save the key of the userMail
        var userMailKey = entry.keys.firstWhere(
            (element) => entry[element] == userMail,
            orElse: () => '');

        if (userMailKey.isNotEmpty) {
          // Save the key of the userMail
          userMailKey = userMailKey.substring(0, 2);

          // Save the team at the key
          var team = int.parse(entry[userMailKey] ?? '0');

          // Add the match number and team to the schedule map
          finalData[matchNumber] = [entry.values.elementAt(0), team];
        }
      }
    }
  }
}

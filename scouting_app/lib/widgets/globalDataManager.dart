import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:scouting_demo/services/googleSheetsAPI.dart';

class GlobalDataManager {
  static void getEventYearNotifier(ValueNotifier<String> val) async {
    val.value = await GoogleSheetsAPI()
        .getCellData(sheetName: "Admin Controls", row: 3, col: 1);

    log("Event year changed to ${val.value}",
        name: "Global Data Manager - Event Year Notifier");
  }

  static void getEventKeyNotifier(ValueNotifier<String> val) async {
    val.value = await GoogleSheetsAPI()
        .getCellData(sheetName: "Admin Controls", row: 3, col: 2);

    log("Event key changed to ${val.value}",
        name: "Global Data Manager - Event Key Notifier");
  }

  static Future<String> getEventYear() async {
    return await GoogleSheetsAPI()
        .getCellData(sheetName: "Admin Controls", row: 3, col: 1);
  }

  static Future<String> getEventKey() async {
    return await GoogleSheetsAPI()
        .getCellData(sheetName: "Admin Controls", row: 3, col: 2);
  }
}

import 'dart:developer';

import 'package:gsheets/gsheets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scouting_demo/First_api/match.dart';
import 'package:scouting_demo/widgets/userManager.dart';

class GoogleSheetsAPI {
  static const _credentials = r'''{
  CLASSIFIED
  }''';

  static const _spreadsheetId = '1m6VhT-YZuoyaHtbXGBN-bhlJAdbhHBDAzTVQgytiaMk';
  static var gsheets = GSheets(_credentials);
  static var ss = gsheets.spreadsheet(_spreadsheetId);

  void updateSheet(String state) async {
    var _testCount = 0;

    while (true) {
      try {
        // Saving the 'scouters' sheet to a variable
        final sheet = (await ss).worksheetByTitle("Scouters");

        int rowIndex = 2;
        for (var row in await sheet!.values.column(2, fromRow: 2)) {
          if (row == UserManager().user!.email) {
            break;
          }

          rowIndex += 1;
        }

        // Update the data at the cell (add 1 to the current value)
        await sheet.values.insertValue(state, column: 4, row: rowIndex);

        // Saving the version to the sheet
        saveCurrentVersion();

        // Exit the loop
        break;
      } catch (e) {
        if (_testCount > 20) {
          break;
        }
        log(e.toString());
        // If the update fails, try again in 5 seconds
        await Future.delayed(const Duration(seconds: 5));
        _testCount += 1;
      }
    }
  }

  void saveBackupData(
      {required Map<String, dynamic> data,
      String name = "RegResponses"}) async {
    var _testCount = 0;
    while (true) {
      try {
        final gsheets = GSheets(_credentials);
        // fetch spreadsheet by its id
        final ss = await gsheets.spreadsheet(_spreadsheetId);

        var sheet = ss.worksheetByTitle(name);
        sheet ??= await ss.addWorksheet(name);

        await sheet.values.map.appendRow(data);

        return;
      } catch (e) {
        log(e.toString(), name: "ERROR - saveBackupData", level: 1, error: e);

        if (_testCount > 20) {
          break;
        }
        // Sleep for 30 seconds
        await Future.delayed(const Duration(seconds: 30));
        _testCount += 1;
      }
    }
  }

  Future<String> getCellData(
      {required String sheetName, required int row, required int col}) async {
    // Saving the 'scouters' sheet to a variable
    final sheet = (await ss).worksheetByTitle(sheetName);

    return await sheet!.values.value(column: col, row: row);
  }

  void saveCurrentVersion() async {
    final sheet = (await ss).worksheetByTitle("Scouters");

    int rowIndex = 2;
    for (var row in await sheet!.values.column(2, fromRow: 2)) {
      if (row == UserManager().user!.email) {
        break;
      }

      rowIndex += 1;
    }

    var packageInfo = await PackageInfo.fromPlatform();

    await sheet.values
        .insertValue(packageInfo.version, column: 5, row: rowIndex);
  }

  Future<List<Map<String, String>>?> getMap({required String title}) async {
    var sheet = (await ss).worksheetByTitle(title);

    var data = sheet!.values.map.allRows();
    return data;
  }
}

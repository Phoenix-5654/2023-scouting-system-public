import 'dart:developer';

import 'package:gsheets/gsheets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scouting_demo/First_api/match.dart';
import 'package:scouting_demo/widgets/userManager.dart';

class GoogleSheetsAPI {
  static const _credentials = r'''{
  "type": "service_account",
  "project_id": "scoutingtest-bf950",
  "private_key_id": "31196a3006cf3b7caacb0e43bd66581c1be2d2e8",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCpfMuQzyF6flSg\nNwgyTqzn1BXWRYQl7jmV4cKv3iyLdrTOuxJAD3Vf3ZfXf3prNTewleHdJNYhlgMl\nDyNMFvbZICM7WJbxZ8NNdH6b248hSTnYACba9iLmQ1VWfZu5dsww7jxl3etBg8o1\nC9CMJxKdvk7r2e0ASZW+/JjA5OyPS/B6QsT99KnaGZ+jmKuNPpEnnJDQ/F6aleqB\nkP7+JhLBSrDJdI381ptg0z+5tMStxThwR7poIMpOMubqCj2iEQOZFTSyVMJEMtXL\n6vsPJdN8aMbC157lx5wjKxPp9fRiBs3mUzolcBwgitzyCYN/bbdGSsBEm8voGtzY\n/LQcJay7AgMBAAECggEATsDCBgN41uYkhF2N3XJZPU965hlfEhDjiRVh1T4zDIqX\n8QdTr5h/PZBFociGJZKQ0eiTDqKzLN/7jhi+mfiBstoQBN9hI8LHKRJcUidvFlRk\nIE3RwCRmiv/2gz3SQhdFQecxAVRgoAyQxJ08xiLRr6JiIY0dZujKP/g3Mkos8Vfi\nN0TPkV5qmuF0ZY8ejjd/l+6h4lrP2GLmugosnWvBLIKcq4aQg5IadUnj6QHDJ7io\n7ibqFZTIPRiqqceMJtwAZKP1+MhmnozzYwCtS3oyR3mL42PrUr4wz+mpIuHnsauR\nkX1Vvjyzv4wuNNJb/HGl6zhV4Z6SBpA5h8MGbg4QQQKBgQDWr1NVFaNqCJe3HcEK\nZ2KmPLjAhxSZOBAymjUY5IfzFxrzRwQuWCsgWCfOfUQbnKhnujVa8YeJOT/cn7wS\nPsBVwyDF7jIj8Q1TKCF/QytX1Okm2+/ptB8Gppxfc4m2oshSIOtLIBgo6gjLp6lY\nxM+CFeoT6pdFd83Y3TMkmgLjwwKBgQDKGsXzmtvCApF7yErvN8PKxnQXKluQF+Gx\n4GyfYvRSGkQbrg8olBHj9En7at1OkKBkG2PqZ5O5YeEvutXWQjEK6LctMBcwvoUp\ndlK+x6UXEBQ58B7VLyhNRbmjLIT4AkStXJEzOCqjYY0D3XQ8OZQiLr6d8Wa306YX\nhVDbIC1bqQKBgBS+2oGlVqY/cFG8qVPVC75ercfFBeOMfFw3dJwUMWL3P550pV3J\nHVnByw70Iem9KLTlVJSWNG+5PYeXU/g7YiCne3pE+0ln2M7JWPtQRVb2dxVPOY7O\n3hSpcwDyTEN+1XbCQZp/3nXNr83mRMIUOq0qavVDvRx0aErljTSjQVY7AoGAGCSs\noxZLzFhsMsJRmVQrEo00jxPjTkpcDtjFgSDcGPbETh4z92AA5x9mux8gAuOqFWtk\nOztWXV4A/aevJeJQY4I7Z62IB62q0LIu3lWRNjkYgXda55KzmM+Mhp6p38q9k4ws\nWFcMWOotY1nQKeWi+ZZl9Q5CfBFPlR269AJbCMkCgYAMf/Fq3GAOSos0JuZFms8e\nAfMj7SVBLfisgWj0rftRBw6oWN06Td7b39OSL0Zp4Dg1p8+KEfuDFOmDaca9jv8/\n9O0Zc77QPF1y0UDQjGm3Q6rIJR5Zomwe0uYw5jKe13sJSKsErgg6eEWmlAf0nTJd\nN+vwMWyllxSCrh11vR6nQw==\n-----END PRIVATE KEY-----\n",
  "client_email": "sheets-api-1@scoutingtest-bf950.iam.gserviceaccount.com",
  "client_id": "110879843132038626220",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/sheets-api-1%40scoutingtest-bf950.iam.gserviceaccount.com"
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

// // sales_excel_controller.dart
//
// import 'dart:io';
//
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
//
// import '../widget/snakbar.dart';
//
// class SalesExcelController
//     extends GetxController {
//
//   var isLoading = false.obs;
//
//   Future<void> downloadExcel({
//
//     required String phone,
//     required String fromDate,
//     required String toDate,
//
//   }) async {
//
//     try {
//
//       isLoading.value = true;
//
//       // 🔥 API URL
//       String url =
//           "https://smartpos.anklegaming.biz/APIs/APIs.asmx/DownloadSalesExcel"
//           "?token=SLDFKAJELWJLKJLKSJK"
//           "&Phone=$phone"
//           "&FromDate=$fromDate"
//           "&ToDate=$toDate";
//
//       print("API URL : $url");
//
//       // 🔥 API CALL
//       var response =
//       await http.get(
//         Uri.parse(url),
//       );
//
//       print(
//           "STATUS CODE : ${response.statusCode}");
//
//       // 🔥 CHECK RESPONSE
//       if (response.statusCode == 200) {
//
//         // 🔥 DEBUG RESPONSE
//         print(
//             "CONTENT TYPE : ${response.headers['content-type']}");
//
//         print(
//             "BODY START : ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}");
//
//         // 🔥 DOWNLOAD FOLDER
//         Directory directory;
//
//         if (Platform.isAndroid) {
//
//           directory =
//               Directory(
//                   "/storage/emulated/0/Download");
//
//         } else {
//
//           directory =
//           await getApplicationDocumentsDirectory();
//         }
//
//         // 🔥 CREATE FOLDER IF NOT EXISTS
//         if (!await directory.exists()) {
//
//           await directory.create(
//             recursive: true,
//           );
//         }
//
//         // 🔥 FILE PATH
//         String filePath =
//             "${directory.path}/SalesReport_${DateTime.now().millisecondsSinceEpoch}.xls";
//
//         // 🔥 FILE CREATE
//         File file =
//         File(filePath);
//
//         // 🔥 SAVE FILE
//         await file.writeAsBytes(
//           response.bodyBytes,
//           flush: true,
//         );
//
//         print(
//             "FILE SAVED : $filePath");
//
//         // 🔥 CHECK FILE SIZE
//         int fileSize =
//         await file.length();
//
//         print(
//             "FILE SIZE : $fileSize");
//
//         // 🔥 FILE EMPTY CHECK
//         if (fileSize <= 0) {
//
//           // Get.snackbar(
//           //   "Error",
//           //   "Downloaded File Empty",
//           // );
//           NeuSnackbar.warning("Downloaded File Empty");
//
//           return;
//         }
//
//         // 🔥 SUCCESS
//         // Get.snackbar(
//         //   "Success",
//         //   "Excel Downloaded Successfully",
//         // );
//
//         // 🔥 OPEN FILE
//         final result =
//         await OpenFilex.open(filePath);
//
//         print(
//             "OPEN RESULT : ${result.message}");
//
//       } else {
//
//         Get.snackbar(
//           "Error",
//           "Server Error : ${response.statusCode}",
//         );
//       }
//
//     } catch (e) {
//
//       print(
//           "DOWNLOAD ERROR : $e");
//
//       Get.snackbar(
//         "Error",
//         e.toString(),
//       );
//
//     } finally {
//
//       isLoading.value = false;
//     }
//   }
// }

// sales_excel_controller.dart

import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../widget/snakbar.dart';

class SalesExcelController extends GetxController {

  var isLoading = false.obs;

  Future<String?> downloadExcel({

    required String phone,
    required String fromDate,
    required String toDate,

  }) async {

    try {

      isLoading.value = true;

      // 🔥 API URL
      String url =
          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/DownloadSalesExcel"
          "?token=SLDFKAJELWJLKJLKSJK"
          "&Phone=$phone"
          "&FromDate=$fromDate"
          "&ToDate=$toDate";

      print("API URL : $url");

      // 🔥 API CALL
      var response = await http.get(
        Uri.parse(url),
      );

      print(
          "STATUS CODE : ${response.statusCode}");

      // 🔥 CHECK RESPONSE
      if (response.statusCode == 200) {

        // 🔥 DEBUG RESPONSE
        print(
            "CONTENT TYPE : ${response.headers['content-type']}");

        print(
            "BODY START : ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}");

        // 🔥 DOWNLOAD FOLDER
        Directory directory;

        if (Platform.isAndroid) {

          directory =
              Directory(
                  "/storage/emulated/0/Download");

        } else {

          directory =
          await getApplicationDocumentsDirectory();
        }

        // 🔥 CREATE FOLDER IF NOT EXISTS
        if (!await directory.exists()) {

          await directory.create(
            recursive: true,
          );
        }

        // 🔥 FILE PATH
        String filePath =
            "${directory.path}/SalesReport_${DateTime.now().millisecondsSinceEpoch}.xls";

        // 🔥 FILE CREATE
        File file = File(filePath);

        // 🔥 SAVE FILE
        await file.writeAsBytes(
          response.bodyBytes,
          flush: true,
        );

        print(
            "FILE SAVED : $filePath");

        // 🔥 CHECK FILE SIZE
        int fileSize =
        await file.length();

        print(
            "FILE SIZE : $fileSize");

        // 🔥 FILE EMPTY CHECK
        if (fileSize <= 0) {

          NeuSnackbar.warning(
              "Downloaded File Empty");

          return null;
        }

        // 🔥 SUCCESS
        NeuSnackbar.success(
            "Excel Downloaded Successfully");

        // 🔥 RETURN FILE PATH
        return filePath;

      } else {

        Get.snackbar(
          "Error",
          "Server Error : ${response.statusCode}",
        );

        return null;
      }

    } catch (e) {

      print(
          "DOWNLOAD ERROR : $e");

      Get.snackbar(
        "Error",
        e.toString(),
      );

      return null;

    } finally {

      isLoading.value = false;
    }
  }
}
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../widget/snakbar.dart';
class ShowInventoryController
    extends GetxController {

  var isLoading = false.obs;

  /// ORIGINAL LIST
  RxList inventoryList = [].obs;

  /// FILTERED LIST
  RxList filteredList = [].obs;

  Future<void> getInventory({

    required String phone,

  }) async {

    try {

      isLoading.value = true;

      final url = Uri.parse(

        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/ShowInventory"

            "?token=SLDFKAJELWJLKJLKSJK"

            "&Phone=$phone",
      );

      print(url);

      final response =
      await http.get(url);

      print(response.body);

      if (response.statusCode == 200) {

        final data =
        jsonDecode(response.body);

        /// SAVE ORIGINAL
        inventoryList.value = data;

        /// SAVE FILTERED
        filteredList.value = data;

      } else {

        NeuSnackbar.error(
          "Server Error",
        );
      }

    } catch (e) {

      print(e);

      NeuSnackbar.error(
        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }

  /// 🔥 SEARCH FILTER
  void filterInventory(String value) {

    if (value.isEmpty) {

      filteredList.value =
          inventoryList;

      return;
    }

    filteredList.value =

        inventoryList.where((item) {

          final itemName =

          item["ItemName"]
              .toString()
              .toLowerCase();

          final barcode =

          item["Barcode"]
              .toString()
              .toLowerCase();

          final query =
          value.toLowerCase();

          return itemName.contains(query)

              ||

              barcode.contains(query);

        }).toList();
  }
}
// class ShowInventoryController
//     extends GetxController {
//
//   var isLoading = false.obs;
//
//   // 🔥 INVENTORY LIST
//   var inventoryList = [].obs;
//
//
//   Future<void> getInventory({
//     required String phone,
//   }) async {
//
//     try {
//
//       isLoading.value = true;
//
//       final url = Uri.parse(
//
//         "https://smartpos.anklegaming.biz/APIs/APIs.asmx/ShowInventory"
//
//             "?token=SLDFKAJELWJLKJLKSJK"
//
//             "&Phone=$phone",
//       );
//
//       print("=========== URL ===========");
//
//       print(url);
//
//       final response =
//       await http.get(url);
//
//       print("=========== RESPONSE ===========");
//
//       print(response.body);
//
//       if (response.statusCode == 200) {
//
//         final data =
//         jsonDecode(response.body);
//
//         // 🔥 SAVE LIST
//         inventoryList.value = data;
//
//       } else {
//
//         NeuSnackbar.error(
//           "Server Error",
//         );
//       }
//
//     } catch (e) {
//
//       print(e.toString());
//
//       NeuSnackbar.error(
//         e.toString(),
//       );
//
//     } finally {
//
//       isLoading.value = false;
//     }
//   }
// }

class ItemMaster {
  final String name;
  final String unit;
  double rate;
  final String barcode;
  final String gst;


  ItemMaster({
    required this.name,
    required this.unit,
    required this.rate,
    required this.barcode,
    required this.gst,
  });

  factory ItemMaster.fromJson(Map<String, dynamic> json) {
    return ItemMaster(
      name: json["ItemName"] ?? "",
      unit: json["Type"] ?? "",
      rate: double.tryParse(
        json["SalePrice"].toString(),
      ) ??
          0,
      gst:
      json["Gst"]?.toString() ?? "0",
      barcode:
      json["Barcode"]?.toString() ?? "",

    );
  }
}

class PosShowInventoryController
    extends GetxController {

  var isLoading = false.obs;

  /// 🔥 API ITEMS
  RxList<ItemMaster> inventoryList =
      <ItemMaster>[].obs;

  Future<void> getInventory({
    required String phone,
  }) async {

    try {

      isLoading.value = true;

      final url = Uri.parse(

        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/ShowInventory"

            "?token=SLDFKAJELWJLKJLKSJK"

            "&Phone=$phone",
      );

      print("=========== URL ===========");

      print(url);

      final response =
      await http.get(url);

      print("=========== RESPONSE ===========");

      print(response.body);

      if (response.statusCode == 200) {

        final List data =
        jsonDecode(response.body);

        /// 🔥 JSON TO MODEL
        inventoryList.value =
            data.map<ItemMaster>((e) {

              return ItemMaster(

                name: e["ItemName"] ?? "",

                unit: e["Type"] ?? "",

                gst:
                e["Gst"]?.toString() ?? "0",

                rate: double.tryParse(
                  e["SalePrice"].toString(),
                ) ??
                    0,


              barcode:
              e["Barcode"]?.toString() ?? "",
              );
            }).toList();

      } else {

        NeuSnackbar.error(
          "Server Error",
        );
      }

    } catch (e) {

      print(e.toString());

      NeuSnackbar.error(
        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }
}
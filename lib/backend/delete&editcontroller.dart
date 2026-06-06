import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../widget/snakbar.dart';

class InventoryActionController
    extends GetxController {

  var isLoading = false.obs;

  var deletingId = ''.obs;

  // ─────────────────────────────
  // DELETE INVENTORY
  // ─────────────────────────────

  Future<bool> deleteInventory({

    required String id,

  }) async {

    try {

      isLoading.value = true;

      deletingId.value = id;

      final response = await http.get(

        Uri.parse(

          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/DeleteInventory?token=SLDFKAJELWJLKJLKSJK&id=$id",
        ),
      );

      if (response.statusCode == 200) {

        final data =
        jsonDecode(response.body);

        if (data["Message"] ==
            "Deleted Successfully!") {

          NeuSnackbar.success(
            "Deleted Successfully",
          );

          return true;
        }
      }

      NeuSnackbar.error(
        "Delete Failed",
      );

      return false;

    } catch (e) {

      NeuSnackbar.error(
        e.toString(),
      );

      return false;

    } finally {

      isLoading.value = false;

      deletingId.value = '';
    }
  }

  // ─────────────────────────────
  // UPDATE INVENTORY
  // ─────────────────────────────
  Future<bool> updateInventory({

    required String id,

    required String itemName,

    required String mrpOld,

    required String salePrice,

    required String type,

    required String intialStock,

    required String barcode,

    required String phone,
    required String gst,

  }) async {

    try {

      isLoading.value = true;

      // 🔥 DEBUG PRINT
      print("ID: $id");

      print("ItemName: $itemName");

      print("MRP: $mrpOld");

      print("SalePrice: $salePrice");

      print("Type: $type");

      print("Stock: $intialStock");

      print("Barcode: $barcode");

      print("Phone: $phone");

      // 🔥 SAFE URL
      final uri = Uri.parse(

        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/UpdateInventory",

      ).replace(

        queryParameters: {

          "token":
          "SLDFKAJELWJLKJLKSJK",

          "id":
          id,

          "ItemName":
          itemName,

          "MrpOld":
          mrpOld,

          "SalePrice":
          salePrice,

          "Type":
          type,

          "IntialStock":
          intialStock,

          "Barcode":
          barcode,

          "Phone":
          phone,
          "Gst":
          gst,
        },
      );

      // 🔥 FULL URL PRINT
      print(uri.toString());

      final response =
      await http.get(uri);

      // 🔥 RESPONSE PRINT
      print(response.body);

      print(response.statusCode);

      if (response.statusCode == 200) {

        final data =
        jsonDecode(response.body);

        print(data);

        if (data["Message"] ==
            "Updated Successfully!") {

          NeuSnackbar.success(
            "Updated Successfully",
          );

          return true;
        }
      }

      NeuSnackbar.error(
        "Update Failed",
      );

      return false;

    } catch (e) {

      print(e);

      NeuSnackbar.error(
        e.toString(),
      );

      return false;

    } finally {

      isLoading.value = false;
    }
  }
}
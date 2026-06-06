import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../widget/snakbar.dart';

class AddInventoryController
    extends GetxController {

  var isLoading = false.obs;

  Future<void> addInventory({

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

      final url = Uri.parse(

        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/AddInventory"

            "?token=SLDFKAJELWJLKJLKSJK"

            "&ItemName=$itemName"

            "&MrpOld=$mrpOld"

            "&SalePrice=$salePrice"

            "&Type=$type"

            "&IntialStock=$intialStock"

            "&Barcode=$barcode"

            "&Phone=$phone"
        "&Gst=$gst",
      );

      print("=========== API URL ===========");
      print("barcode$barcode");

      print(url);

      final response =
      await http.get(url);

      print("=========== RESPONSE ===========");

      print(response.body);

      if (response.statusCode == 200) {

        final data =
        jsonDecode(response.body);

        String message =
        data["Message"].toString();

        // ✅ SUCCESS
        if (message ==
            "Inserted Successfully!") {

          NeuSnackbar.success(
            message,
          );

        } else {

          // ❌ ERROR
          NeuSnackbar.error(
            message,
          );
        }

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
// 🔥 showbarcodeinventory_controller.dart

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../widget/snakbar.dart';
// 🔥 barcode_inventory_model.dart

class BarcodeInventoryModel {

  final String id;

  final String itemName;

  final String mrpOld;

  final String salePrice;

  final String type;

  final String intialStock;

  final String barcode;

  final String phone;

  BarcodeInventoryModel({

    required this.id,

    required this.itemName,

    required this.mrpOld,

    required this.salePrice,

    required this.type,

    required this.intialStock,

    required this.barcode,

    required this.phone,
  });

  factory BarcodeInventoryModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return BarcodeInventoryModel(

      id:
      json["id"]
          .toString(),

      itemName:
      json["ItemName"]
          .toString(),

      mrpOld:
      json["MrpOld"]
          .toString(),

      salePrice:
      json["SalePrice"]
          .toString(),

      type:
      json["Type"]
          .toString(),

      intialStock:
      json["IntialStock"]
          .toString(),

      barcode:
      json["Barcode"]
          .toString(),

      phone:
      json["Phone"]
          .toString(),
    );
  }
}

class ShowBarcodeInventoryController
    extends GetxController {

  var isLoading = false.obs;

  var barcodeItem =
  Rxn<BarcodeInventoryModel>();

  Future<void> getBarcodeItem({

    required String barcode,

  }) async {

    try {

      isLoading.value = true;

      final uri = Uri.parse(

        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/ShowBarcodeInventory"

            "?token=SLDFKAJELWJLKJLKSJK"

            "&Barcode=$barcode",
      );

      print(uri);

      final response =
      await http.get(uri);

      print(response.body);

      if (response.statusCode == 200) {

        final List data =
        jsonDecode(response.body);

        if (data.isNotEmpty) {

          barcodeItem.value =

              BarcodeInventoryModel
                  .fromJson(
                data.first,
              );

        } else {

          NeuSnackbar.error(
            "Item Not Found",
          );
        }

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
}
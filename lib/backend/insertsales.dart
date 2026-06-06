import 'dart:convert';

import 'package:flutter/material.dart';

import '../widget/snakbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart'
as http;

import '../widget/snakbar.dart';

class SaveBillController
    extends GetxController {

  var isLoading = false.obs;

  Future<bool> saveBillApi({

    required String token,
    required String shopName,
    required String address,
    required String dates,
    required String times,
    required String cashier,
    required String mode,
    required String customer,
    required String mobile,
    required String items,
    required String phone,

  }) async {

    try {

      isLoading.value = true;

      NeuSnackbar.info(
        "Saving Bill...",
      );

      var response =
      await http.post(

        Uri.parse(
          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/InsertSales",
        ),

        body: {

          "token": token,
          "ShopName": shopName,
          "Address": address,
          "Dates": dates,
          "Times": times,
          "Cashier": cashier,
          "Mode": mode,
          "Customer": customer,
          "Mobile": mobile,
          "Items": items,
          "Phone": phone,
        },
      );

      print("━━━━━━━━━━━━━━━━━━━━━━");
      print("STATUS CODE => ${response.statusCode}");
      print("RAW RESPONSE => ${response.body}");
      print("━━━━━━━━━━━━━━━━━━━━━━");

      isLoading.value = false;

      if (response.statusCode == 200) {

        var data =
        jsonDecode(
          response.body,
        );

        print(
          "DECODED RESPONSE => $data",
        );

        if (data["Message"]
            .toString()
            .contains("Inserted")) {

          NeuSnackbar.success(
            "Bill Generated Successfully",
          );

          return true;

        } else {

          NeuSnackbar.error(
            data["Message"]
                .toString(),
          );

          return false;
        }

      } else {

        NeuSnackbar.error(
          "Server Error : ${response.statusCode}",
        );

        return false;
      }

    } catch (e) {

      isLoading.value = false;

      print("API ERROR => $e");

      NeuSnackbar.error(
        e.toString(),
      );

      return false;
    }
  }
}
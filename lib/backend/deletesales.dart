import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart'
as http;

import '../widget/snakbar.dart';

class DeleteSalesController
    extends GetxController {

  var deletingId = ''.obs;

  Future<bool> deleteSale({
    required String id,
  }) async {

    try {

      deletingId.value = id;

      final response =
      await http.get(

        Uri.parse(
          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/DeleteSales?token=SLDFKAJELWJLKJLKSJK&id=$id",
        ),
      );

      print(
        "STATUS => ${response.statusCode}",
      );

      print(
        "BODY => ${response.body}",
      );

      if (response.statusCode == 200) {

        final data =
        jsonDecode(
          response.body,
        );

        if (data["Message"] ==
            "Deleted Successfully!") {
          NeuSnackbar.success(
            "Iteam Deleted Successfully...",
          );




          return true;

        } else {

          Get.snackbar(

            "Error",

            "Delete Failed",
          );

          return false;
        }

      } else {

        Get.snackbar(

          "Error",

          "Server Error",
        );

        return false;
      }

    } catch (e) {

      print(e);

      Get.snackbar(

        "Error",

        e.toString(),
      );

      return false;

    } finally {

      deletingId.value = '';
    }
  }
}
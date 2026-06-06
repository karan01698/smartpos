import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
class TermsController extends GetxController {

  var isLoading = false.obs;

  final TextEditingController
  termsCtrl =
  TextEditingController();

  Future<void> fetchTerms() async {

    try {

      isLoading.value = true;

      final url = Uri.parse(
        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/ShowForms"
            "?token=SLDFKAJELWJLKJLKSJK"
            "&FormHeading=About Us",
      );

      final response =
      await http.get(url);

      print(response.body);

      if(response.statusCode == 200){

        final data =
        jsonDecode(response.body);

        print(data);

        if(data is List &&
            data.isNotEmpty){

          /// 🔥 API DATA SET
          termsCtrl.text =
              data[0]["FormContent"]
                  .toString();

          update();
        }

      } else {

        Get.snackbar(
          "Error",
          "Failed To Load",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

    } catch (e) {

      print(e);

      Get.snackbar(
        "Exception",
        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }

  @override
  void onClose() {

    termsCtrl.dispose();

    super.onClose();
  }
}
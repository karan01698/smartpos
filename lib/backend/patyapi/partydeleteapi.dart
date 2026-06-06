// delete_party_controller.dart

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../widget/snakbar.dart';
import 'insertapi.dart';


class DeletePartyController
    extends GetxController {

  final ShowPartyController
  partyController =
  Get.put(ShowPartyController());

  var isLoading = false.obs;

  Future<void> deleteParty({

    required String id,

    required String type,

    required String venPhone,

  }) async {

    try {

      isLoading.value = true;

      String url =
          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/DeleteParty";

      var response =
      await http.post(

        Uri.parse(url),

        headers: {

          "Content-Type":
          "application/x-www-form-urlencoded",
        },

        body: {

          "token":
          "SLDFKAJELWJLKJLKSJK",

          "id":
          id,
        },
      );

      print(
          "STATUS CODE : ${response.statusCode}");

      print(
          "RESPONSE : ${response.body}");

      if (response.statusCode == 200) {

        var data =
        jsonDecode(response.body);

        if (data["Message"]
            .toString()
            .trim() ==
            "Deleted Successfully") {

          // REFRESH LIST
          partyController.fetchParty(

            type: type,

            venPhone: venPhone,
          );

          NeuSnackbar.error(
              "Data Deleted Successfully");

        } else {

          NeuSnackbar.error(

            data["Message"]
                .toString(),
          );
        }

      } else {

        NeuSnackbar.error(
            "Server Error");
      }

    } catch (e) {

      print(
          "DELETE PARTY ERROR : $e");

      NeuSnackbar.error(
          e.toString());

    } finally {

      isLoading.value = false;
    }
  }
}
// insert_party_controller.dart

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../widget/snakbar.dart';

class InsertPartyController extends GetxController {
  final ShowPartyController partyController = Get.put(ShowPartyController());
  var isLoading = false.obs;

  Future<void> insertParty({

    required String name,
    required String phone,
    required String type,
    required String venPhone,

  }) async {

    try {

      isLoading.value = true;

      String url =
          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/InsertParty";

      var response = await http.post(

        Uri.parse(url),

        headers: {
          "Content-Type":
          "application/x-www-form-urlencoded",
        },

        body: {

          "token": "SLDFKAJELWJLKJLKSJK",

          "Name": name,

          "Phone": phone,

          "Type": type,

          "VenPhone": venPhone,
        },
      );

      print(
          "STATUS CODE : ${response.statusCode}");

      print(
          "RESPONSE : ${response.body}");

      if (response.statusCode == 200) {

        var data =
        jsonDecode(response.body);

        if (data["Message"] ==
            "Inserted Successfully") {
          partyController.fetchParty(

            type: type,


            venPhone: venPhone,
          );

          NeuSnackbar.success("Party Added Successfully");

        } else {



          NeuSnackbar.error(data["Message"].toString(),);
        }

      } else {

        Get.snackbar(
          "Error",
          "Server Error",
        );
      }

    } catch (e) {

      print(
          "INSERT PARTY ERROR : $e");

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }
}

// show_party_model.dart

class ShowPartyModel {

  final String id;
  final String name;
  final String phone;
  final String type;
  final String venPhone;

  ShowPartyModel({

    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    required this.venPhone,
  });

  factory ShowPartyModel.fromJson(
      Map<String, dynamic> json) {

    return ShowPartyModel(

      id: json["id"].toString(),

      name: json["Name"] ?? "",

      phone: json["Phone"] ?? "",

      type: json["Type"] ?? "",

      venPhone: json["VenPhone"] ?? "",
    );
  }
}

// show_party_controller.dart


class ShowPartyController
    extends GetxController {

  var isLoading = false.obs;

  RxList<ShowPartyModel>
  partyList =
      <ShowPartyModel>[].obs;

  // 🔥 SEARCH LIST
  RxList<ShowPartyModel>
  filteredList =
      <ShowPartyModel>[].obs;

  // 🔥 SEARCH TEXT
  var searchText = "".obs;

  Future<void> fetchParty({

    required String type,
    required String venPhone,

  }) async {

    try {

      isLoading.value = true;

      String url =
          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/ShowParty"
          "?token=SLDFKAJELWJLKJLKSJK"
          "&Type=$type"
          "&VenPhone=$venPhone";

      print(url);

      var response =
      await http.get(
        Uri.parse(url),
      );

      print(response.body);

      if (response.statusCode == 200) {

        List data =
        jsonDecode(response.body);

        partyList.value =
            data.map((e) {

              return ShowPartyModel
                  .fromJson(e);

            }).toList();

        // 🔥 DEFAULT ALL DATA
        filteredList.value =
            partyList;

      } else {

        Get.snackbar(
          "Error",
          "Server Error",
        );
      }

    } catch (e) {

      print(e);

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }

  // 🔥 SEARCH METHOD
  void searchParty(String value) {

    searchText.value = value;

    if (value.trim().isEmpty) {

      filteredList.value =
          partyList;

    } else {

      filteredList.value =
          partyList.where((item) {

            return item.name
                .toLowerCase()
                .contains(
              value.toLowerCase(),
            ) ||

                item.phone
                    .toLowerCase()
                    .contains(
                  value.toLowerCase(),
                );

          }).toList();
    }
  }
}
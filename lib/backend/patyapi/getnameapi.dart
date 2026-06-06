// 🔥 getname_model.dart

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../widget/snakbar.dart';

class GetNameModel {

  final String customer;

  GetNameModel({
    required this.customer,
  });

  factory GetNameModel.fromJson(Map<String, dynamic> json) {

    return GetNameModel(

      customer: json["Customer"]?.toString() ?? "",
    );
  }
}// 🔥 getname_controller.dart



class GetNameController extends GetxController {

  var isLoading = false.obs;

  var customerData = <GetNameModel>[].obs;

  Future<void> getCustomerName({

    required String phone,
    required String mobile,

  }) async {

    try {

      isLoading.value = true;

      final url = Uri.parse(

        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/GetName"
            "?token=SLDFKAJELWJLKJLKSJK"
            "&Phone=$phone"
            "&Mobile=$mobile",
      );

      print("=========== GET NAME URL ===========");
      print(url);

      final response = await http.get(url);

      print("=========== GET NAME RESPONSE ===========");
      print(response.body);

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        customerData.value =

            (data as List)

                .map((e) => GetNameModel.fromJson(e))
                .toList();

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
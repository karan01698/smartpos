import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart'
as http;


class UdharModel {

  final int id;
  final String shopName;
  final String address;
  final String dates;
  final String times;
  final String cashier;
  final String mode;
  final String customer;
  final String mobile;
  final String items;
  final String phone;
  final String status;

  UdharModel({

    required this.id,
    required this.shopName,
    required this.address,
    required this.dates,
    required this.times,
    required this.cashier,
    required this.mode,
    required this.customer,
    required this.mobile,
    required this.items,
    required this.phone,
    required this.status,
  });

  factory UdharModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return UdharModel(

      id: int.tryParse(
        json["id"].toString(),
      ) ?? 0,

      shopName:
      json["ShopName"]
          ?.toString() ??
          "",

      address:
      json["Address"]
          ?.toString() ??
          "",

      dates:
      json["Dates"]
          ?.toString() ??
          "",

      times:
      json["Times"]
          ?.toString() ??
          "",

      cashier:
      json["Cashier"]
          ?.toString() ??
          "",

      mode:
      json["Mode"]
          ?.toString() ??
          "",

      customer:
      json["Customer"]
          ?.toString() ??
          "",

      mobile:
      json["Mobile"]
          ?.toString() ??
          "",

      items:
      json["Items"]
          ?.toString() ??
          "",

      phone:
      json["Phone"]
          ?.toString() ??
          "",

      status:
      json["Status"]
          ?.toString() ??
          "",
    );
  }
}
class UdharController
    extends GetxController {

  var isLoading = false.obs;

  RxList<UdharModel>
  udharList =
      <UdharModel>[].obs;

  Future<void> fetchUdhar({

    required String mobile,
    required String phone,

  }) async {

    try {

      isLoading(true);

      final response =
      await http.get(

        Uri.parse(

          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/ShowUdhar?token=SLDFKAJELWJLKJLKSJK&Mobile=$mobile&Phone=$phone",
        ),
      );

      if (response.statusCode == 200) {

        final data =
        jsonDecode(response.body);

        udharList.value =

        List<UdharModel>.from(

          data.map(

                (x) => UdharModel.fromJson(x),
          ),
        );
      }

    } catch (e) {

      print(e);

    } finally {

      isLoading(false);
    }
  }
}
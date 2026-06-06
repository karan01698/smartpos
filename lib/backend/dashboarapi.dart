import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class DashboardModel {

  final double todaySales;
  final double todayMarketDue;
  final double monthSales;
  final double monthMarketDue;

  DashboardModel({

    required this.todaySales,
    required this.todayMarketDue,
    required this.monthSales,
    required this.monthMarketDue,
  });

  factory DashboardModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return DashboardModel(

      todaySales:
      double.tryParse(
        json["TodaySales"].toString(),
      ) ?? 0,

      todayMarketDue:
      double.tryParse(
        json["TodayMarketDue"].toString(),
      ) ?? 0,

      monthSales:
      double.tryParse(
        json["MonthSales"].toString(),
      ) ?? 0,

      monthMarketDue:
      double.tryParse(
        json["MonthMarketDue"].toString(),
      ) ?? 0,
    );
  }
}

class DashboardController
    extends GetxController {

  var isLoading = false.obs;

  Rxn<DashboardModel>
  dashboardData =
  Rxn<DashboardModel>();

  Future<void> fetchDashboard({

    required String phone,

  }) async {

    try {

      isLoading(true);

      final response =
      await http.get(

        Uri.parse(

          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/ShowDashboardData?token=SLDFKAJELWJLKJLKSJK&Phone=$phone",
        ),
      );

      if (response.statusCode == 200) {

        final data =
        jsonDecode(response.body);

        if (data is List &&
            data.isNotEmpty) {

          dashboardData.value =
              DashboardModel.fromJson(
                data[0],
              );
        }
      }

    } catch (e) {

      print(e);

    } finally {

      isLoading(false);
    }
  }
}
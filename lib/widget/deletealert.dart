import 'package:flutter/material.dart';

class AppDeleteDialog {

  static Future<bool?> show({

    required BuildContext context,

    String title =
    "Delete Item",

    String message =
    "Are you sure you want to delete this item?",

    String yesText =
    "YES",

    String noText =
    "CANCEL",

    Color yesColor =
        Colors.red,

  }) {

    return showDialog<bool>(

      context: context,

      barrierDismissible: false,

      builder: (_) {

        return AlertDialog(

          shape: RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(20),
          ),

          title: Row(

            children: const [

              Icon(
                Icons.delete_rounded,
                color: Colors.red,
              ),

              SizedBox(width: 8),

              Text(
                "Delete Item",
              ),
            ],
          ),

          content: Text(
            message,
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  context,
                  false,
                );
              },

              child: Text(
                noText,
              ),
            ),

            ElevatedButton(

              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                yesColor,

                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
              ),

              onPressed: () {

                Navigator.pop(
                  context,
                  true,
                );
              },

              child: Text(
                yesText,
              ),
            ),
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:currency_converter_app/global/utils/global.dart';

class AlertDialogWidget {
  alertDialogWidget(
      {required Function checkConnectivity,
      required isConnected,
      required showDialog,
      required BuildContext context,
      required String header,
      required String description,
    
      required String btnText,
      required String semanticsLabel}) {
    return AlertDialog(
      backgroundColor: ConstantHelper.white,
     
      title: Text(
        header,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        description,
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ConstantHelper.blue,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ConstantHelper.sizex12,
                vertical: ConstantHelper.sizex08),
            child: Text(
              btnText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ConstantHelper.sizex12,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          // check connectivity again
          onPressed: () => checkConnectivity(),
        ),
      ],
      actionsPadding: EdgeInsets.symmetric(
          horizontal: ConstantHelper.sizex12, vertical: ConstantHelper.sizex08),
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(ConstantHelper.sizex18))),
    );
  }
}

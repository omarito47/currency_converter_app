import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AlertDialogWidget {
  alertDialogWidget(
      {required Function checkConnectivity,
      required isConnected,
      required showDialog,
      required BuildContext context,
      required String header,
      required String description,
      required String imagePath,
      required String btnText,
      required String semanticsLabel}) {
    return AlertDialog(
      backgroundColor: Colors.white,
      icon: SvgPicture.asset(
        imagePath,
        semanticsLabel: semanticsLabel,
      ),
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
            backgroundColor: Colors.blue, 
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              btnText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          // check connectivity again
          onPressed: () => checkConnectivity(),
        ),
      ],
      actionsPadding:
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18.0))),
    );
  }
}

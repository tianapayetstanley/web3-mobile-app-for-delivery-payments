import 'package:flutter/material.dart';

enum SnackbarType { success, error, warning, info }

void showSnackbar(
  BuildContext context,
  SnackbarType type,
  String message,
) {
  Color? color;
  if (type == SnackbarType.success) {
    color = Colors.green;
  } else if (type == SnackbarType.error) {
    color = Colors.red;
  } else if (type == SnackbarType.warning) {
    color = Colors.orange;
  } else if (type == SnackbarType.info) {
    color = Colors.grey[600];
  }

  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        width: 300,
      ),
    );
}

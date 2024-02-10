import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:web3_delivery_payments/utils/logger_util.dart';

String decodeErrorResponse(dynamic e) {
  var data = kDebugMode ? e.toString() : 'Something went wrong.';
  logPrint(e);
  if (e is DioException) {
    if (e.error is SocketException) {
      data = 'No Internet Connection';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      data = 'Request timeout';
    } else if (e.type == DioExceptionType.badResponse) {
      final response = e.response;
      try {
        if (response != null && response.data != null) {
          final responseData = response.data as Map;
          data = responseData['msg'] as String;
        }
      } catch (e) {
        data = 'Internal Error Occurred';
      }
    }
  }
  return data;
}

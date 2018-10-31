import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

void handleError(BuildContext context, Object error) {
  if (error is DioError) {
    String message = '网络异常, 请检查网络设置';
    if (error.response != null) {
      switch (error.type) {
        case DioErrorType.CANCEL:
          message = '取消请求';
          break;
        case DioErrorType.CONNECT_TIMEOUT:
          message = '请求超时';
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          message = '接收超时';
          break;
        case DioErrorType.RESPONSE:
          final statusCode = error.response.statusCode;
          if (statusCode >= 400 && statusCode <= 417) {
            message = '访问地址异常，请稍后重试';
          } else if (statusCode >= 500 && statusCode <= 505) {
            message = '服务器繁忙';
          }
          break;
        case DioErrorType.DEFAULT:
          message = '网络异常, 请检查网络设置';
          break;
        default:
          message = '网络异常, 请检查网络设置';
      }
    }
    showError(context, message);
  } else if (error is String) {
    showError(context, error);
  } else {
    showError(context, error.toString());
  }
}

/// 等待页
Future<T> loading<T>(BuildContext context, Future<T> futureTask) {
  showDialog(
    context: context,
    builder: (context) => LoadingWidget(),
    barrierDismissible: false,
  );
  return futureTask.whenComplete(() {
    // 由于showDialog会强制使用rootNavigator, 所以这里pop的时候也要用rootNavigator
    Navigator.of(context, rootNavigator: true).pop(context);
  });
}

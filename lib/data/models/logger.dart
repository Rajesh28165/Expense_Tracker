import 'package:kharchasutra/util/logging.dart';

class LoggerModel {
  final log = logger(LoggerModel);
  String? deviceInfo;
  String? errorType;
  String? errorMessage;
  String? errorDetails;

  LoggerModel({
    this.deviceInfo,
    this.errorType,
    this.errorMessage,
    this.errorDetails,
  });

  LoggerModel.fromJson(Map<String, dynamic> json) {
    deviceInfo = json['deviceInfo'];
    errorType = json['errorType'];
    errorMessage = json['errorMessage'];
    errorDetails = json['errorDetails'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceInfo'] = deviceInfo;
    data['errorType'] = errorType;
    data['errorMessage'] = errorMessage;
    data['errorDetails'] = errorDetails;
    return data;
  }
}

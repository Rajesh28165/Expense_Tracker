import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashData(String input) {
  return sha256
    .convert(utf8.encode(input.trim().toLowerCase()))
    .toString();
}

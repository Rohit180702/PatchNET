import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class CellInfoService {
  static const MethodChannel _channel = MethodChannel('cell_info_channel');
  static const String unwiredLabsApiUrl = 'https://us1.unwiredlabs.com/v2/process.php';

  Future<Map<String, dynamic>> getCellInfo() async {
    try {
      final dynamic cellInfo = await _channel.invokeMethod('getCellInfo');
      if (cellInfo is Map<String, dynamic>) {
        return cellInfo;
      } else if (cellInfo is String) {
        final parsedCellInfo = jsonDecode(cellInfo);
        print(parsedCellInfo);
        if (parsedCellInfo is Map<String, dynamic>) {
          return parsedCellInfo;
        }
      }
      throw Exception('Invalid data type received: $cellInfo');
    } on PlatformException catch (e) {
      throw Exception('Error retrieving cell info: $e');
    }
  }

  Future<Map<String, dynamic>> getTowerLocation(Map<String, dynamic> cellInfo) async {
    try {
      // final token = 'pk.44ee4fe01118e4ddcfce4394146307e9';
      final token = 'pk.84d2e298234ee263b570d4f3620ad0f3';
      final mcc = cellInfo["mcc"];
      final mnc = cellInfo["mnc"];
      final lac = cellInfo["tac"];
      final cid = cellInfo["cid"];

      final requestBody = {
        "token": token,
        "radio": "lte",
        "mcc": mcc,
        "mnc": mnc,
        "cells": [
          {
            "lac": lac,
            "cid": cid,
            "psc": 0
          }
        ],
        "address": 1
      };

      final response = await http.post(
        Uri.parse(unwiredLabsApiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final responseBody = response.body;
        final data = jsonDecode(responseBody);
        final latitude = data['lat'] ?? 0.0;
        final longitude = data['lon'] ?? 0.0;
        final pincode = data['address'] ?? 0.0;
        return {'latitude': latitude, 'longitude': longitude};
      } else {
        throw Exception('Failed to retrieve tower location. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error retrieving tower location: $e');
    }
  }

}

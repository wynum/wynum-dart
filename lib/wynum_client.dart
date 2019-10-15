library wynum_client;

import 'dart:io';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

import 'package:wynum_client/schema.dart';
import 'package:wynum_client/auth_exception.dart';

/// Wynum Client.
class Client {
  final String _secret;
  final String _token;

  final Dio _dio = Dio();

  final String _baseSchmaUrl = "https://api.wynum.com/component";
  final String _baseDataUrl = "https://api.wynum.com/data";

  String _schmaUrl, _dataUrl, identifier;

  Client._(this._secret, this._token) {
    this._schmaUrl = "$_baseSchmaUrl/$_token?secret_key=$_secret";
    this._dataUrl = "$_baseDataUrl/$_token?secret_key=$_secret";
  }

  factory Client.create({@required String secret, @required String token}) =>
      Client._(secret, token);

  Future<List<Schema>> getSchema() async {
    final response = await _dio.get(_schmaUrl);
    final data = response.data;

    _validateResponse(data);

    final schemaJson = data['components'] as List;
    this.identifier = data['identifer'];
    final schemaList = schemaJson
        .map((json) => Schema(json['Property'], json['Type']))
        .toList();
    return schemaList;
  }

  Future<List<dynamic>> getData(
      {int limit,
      List<String> ids,
      String orderBy,
      int start,
      int to,
      Map<String, dynamic> filters}) async {
    Map<String, dynamic> params = {};

    if (limit != null) params['_limit'] = limit;
    if (ids != null) params['_ids'] = ids.join(",");
    if (orderBy != null) params['_order_by'] = orderBy.toUpperCase();
    if (start != null) params['_from'] = start;
    if (to != null) params['_to'] = to;

    if (filters != null) {
      params.addAll(filters);
    }

    final response = await _dio.get(_dataUrl, queryParameters: params);
    final data = response.data;

    _validateResponse(data);
    return data;
  }

  Future<Map<String, dynamic>> postData(Map<String, dynamic> data) async {
    assert(data != null);

    // check for file
    final hasFile = data.keys.any((key) => data[key] is File);

    Response response;
    if (hasFile) {
      final formData = _prepareFormDataForFile(data);
      response = await _dio.post(_dataUrl, data: formData);
    } else {
      response = await _dio.post(_dataUrl, data: data);
    }

    _validateResponse(response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(Map<String, dynamic> data) async {
    assert(data != null);

    // check for file
    final hasFile = data.keys.any((key) => data[key] is File);

    Response response;
    if (hasFile) {
      final formData = _prepareFormDataForFile(data);
      response = await _dio.put(_dataUrl, data: formData);
    } else {
      response = await _dio.put(_dataUrl, data: data);
    }
    _validateResponse(response.data);
    return response.data;
  }

  FormData _prepareFormDataForFile(Map<String, dynamic> data) {
    final FormData formData = FormData();
    for (var key in data.keys) {
      if (data[key] is File) {
        File file = data[key];
        var fileName = basename(file.path);
        formData[key] = UploadFileInfo(file, fileName);
      }
    }
    data.removeWhere((key, val) => val is File);
    formData['inputdata'] = json.encode(data);
    return FormData.from(formData);
  }

  void _validateResponse(dynamic data) {
    if (data is Map) {
      if (data.containsKey("_error")) {
        switch (data['_message']) {
          case "Secret Key Error":
            throw AuthException("Secret Key Error");
          case "Not Found":
            throw Exception("Invalid token");
        }
      }
    }
  }
}

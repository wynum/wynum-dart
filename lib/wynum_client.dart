library wynum_client;

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

import 'package:wynum_client/schema.dart';

/// Wynum Client.
class Client {
  final String _secret;
  final String _token;

  final Dio _dio = Dio();

  final String _baseSchmaUrl = "https://api.wynum.com/component";
  final String _baseDataUrl = "https://api.wynum.com/data";

  String _schmaUrl, _dataUrl, identifier;

  Client._(this._secret, this._token) {
    this._schmaUrl = "$_baseSchmaUrl/$_token";
    this._dataUrl = "$_baseDataUrl/$_token";
  }

  factory Client.create({@required secret, @required token}) =>
      Client._(secret, token);

  Future<List<Schema>> getSchema() async {
    final response = await _dio.get(_schmaUrl);
    final data = response.data;
    final schemaJson = data['components'] as List;
    this.identifier = data['identifer'];
    final schemaList = schemaJson.map((json) =>
        Schema(json['Property'], json['Type'])).toList();
    return schemaList;
  }

  Future<Map<String, dynamic>> get() async {
    final response = await _dio.get(_dataUrl);
    final data = response.data;
    return data;
  }

  Future<Map<String, dynamic>> post(Map<String, dynamic> data) async {
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

    return response.data;
  }

  Future<void> update(Map<String, dynamic> data) async {
    assert(data != null);
    final response = await _dio.put(_dataUrl, data: data);
    return response.data;
  }

  FormData _prepareFormDataForFile(Map<String, dynamic> data) {
    final files = [];

    for (var key in data.keys) {
      if (data[key] is File) {
        File file = data[key];
        var fileName = basename(file.path);
        data[key] = fileName;
        files.add(UploadFileInfo(file, fileName));
      }
    }

    var transformedData = {};
    for (var key in data.keys) {
      var val = data[key];
      switch (val.runtimeType) {
        case String:
          transformedData['"$key"'] = '"$val"';
          break;
        case List:
          val = val.map((tmp) => tmp is String ? '"$tmp"' : tmp).toList();
          transformedData['"$key"'] = val;
          break;
        default:
          transformedData['"$key"'] = val;
      }
    }

    final formData =
        FormData.from({'inputdata': transformedData, 'files': files});
    return formData;
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;

/// Blob type
enum BlobType {
  BlockBlob,
  AppendBlob,
}

/// Azure Storage Exception
class AzureStorageException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, String> headers;
  AzureStorageException(this.message, this.statusCode, this.headers);
}

/// Azure Storage Client
class AzureStorage {
  Map<String, String> config;
  Uint8List accountKey;

  static final String DefaultEndpointsProtocol = 'DefaultEndpointsProtocol';
  static final String EndpointSuffix = 'EndpointSuffix';
  static final String AccountName = 'AccountName';
  static final String AccountKey = 'AccountKey';

  /// Initialize with connection string.
  AzureStorage.parse(String connectionString) {
    try {
      Map<String, String> m = {};
      var items = connectionString.split(';');
      for (var item in items) {
        var i = item.indexOf('=');
        var key = item.substring(0, i);
        var val = item.substring(i + 1);
        m[key] = val;
      }
      config = m;
      accountKey = base64Decode(config[AccountKey]);
    } catch (e) {
      throw Exception('Parse error.');
    }
  }

  @override
  String toString() {
    return config.toString();
  }

  Uri uri({String path = '/', Map<String, String> queryParameters}) {
    var scheme = config[DefaultEndpointsProtocol] ?? 'https';
    var suffix = config[EndpointSuffix] ?? 'core.windows.net';
    var name = config[AccountName];
    return Uri(
        scheme: scheme,
        host: '${name}.blob.${suffix}',
        path: path,
        queryParameters: queryParameters);
  }

  String _canonicalHeaders(Map<String, String> headers) {
    var keys = headers.keys
        .where((i) => i.startsWith('x-ms-'))
        .map((i) => '${i}:${headers[i]}\n')
        .toList();
    keys.sort();
    return keys.join();
  }

  String _canonicalResources(Map<String, String> items) {
    if (items.isEmpty) {
      return '';
    }
    var keys = items.keys.toList();
    keys.sort();
    return keys.map((i) => '\n${i}:${items[i]}').join();
  }

  void sign(http.Request request) {
    request.headers['x-ms-date'] = HttpDate.format(DateTime.now());
    request.headers['x-ms-version'] = '2016-05-31';
    var ce = request.headers['Content-Encoding'] ?? '';
    var cl = request.headers['Content-Language'] ?? '';
    var cz = request.contentLength == 0 ? '' : '${request.contentLength}';
    var cm = request.headers['Content-MD5'] ?? '';
    var ct = request.headers['Content-Type'] ?? '';
    var dt = request.headers['Date'] ?? '';
    var ims = request.headers['If-Modified-Since'] ?? '';
    var imt = request.headers['If-Match'] ?? '';
    var inm = request.headers['If-None-Match'] ?? '';
    var ius = request.headers['If-Unmodified-Since'] ?? '';
    var ran = request.headers['Range'] ?? '';
    var chs = _canonicalHeaders(request.headers);
    var crs = _canonicalResources(request.url.queryParameters);
    var name = config[AccountName];
    var path = request.url.path;
    var sig =
        '${request.method}\n${ce}\n${cl}\n${cz}\n${cm}\n${ct}\n${dt}\n${ims}\n${imt}\n${inm}\n${ius}\n${ran}\n${chs}/${name}${path}${crs}';
    var mac = crypto.Hmac(crypto.sha256, accountKey);
    var digest = base64Encode(mac.convert(utf8.encode(sig)).bytes);
    var auth = 'SharedKey ${name}:${digest}';
    request.headers['Authorization'] = auth;
    //print(sig);
  }

  void sign4Q(http.Request request) {
    request.headers['x-ms-date'] = HttpDate.format(DateTime.now());
    request.headers['x-ms-version'] = '2016-05-31';
    var ce = request.headers['Content-Encoding'] ?? '';
    var cl = request.headers['Content-Language'] ?? '';
    var cz = request.contentLength == 0 ? '' : '${request.contentLength}';
    var cm = request.headers['Content-MD5'] ?? '';
    var ct = request.headers['Content-Type'] ?? '';
    var dt = request.headers['Date'] ?? '';
    var ims = request.headers['If-Modified-Since'] ?? '';
    var imt = request.headers['If-Match'] ?? '';
    var inm = request.headers['If-None-Match'] ?? '';
    var ius = request.headers['If-Unmodified-Since'] ?? '';
    var ran = request.headers['Range'] ?? '';
    var chs = _canonicalHeaders(request.headers);
    var crs = _canonicalResources(request.url.queryParameters);
    var name = config[AccountName];
    var path = request.url.path;
    var sig =
        '${request.method}\n${ce}\n${cl}\n${cz}\n${cm}\n${ct}\n${dt}\n${ims}\n${imt}\n${inm}\n${ius}\n${ran}\n${chs}/${name}/${crs}';
    print('queue sign signature: $sig');
    var mac = crypto.Hmac(crypto.sha256, accountKey);
    var digest = base64Encode(mac.convert(utf8.encode(sig)).bytes);
    var auth = 'SharedKey ${name}:${digest}';
    request.headers['Authorization'] = auth;
    //print(sig);
  }


  void sign4Tables(http.Request request) {

    request.headers['Date'] = HttpDate.format(DateTime.now());
    request.headers['x-ms-date'] = HttpDate.format(DateTime.now());
    request.headers['x-ms-version'] = '2016-05-31';
    var cm = request.headers['Content-MD5'] ?? '';
    var ct = request.headers['Content-Type'] ?? '';
    var crs = _canonicalResources(request.url.queryParameters);
    var dt = request.headers['Date'] ?? '';
    var name = config[AccountName];
    var path = request.url.path;
    var sig =
        '${dt}\n/${name}${path}';
    var mac = crypto.Hmac(crypto.sha256, accountKey);
    var digest = base64Encode(mac.convert(utf8.encode(sig)).bytes);
    var auth = 'SharedKeyLite ${name}:${digest}';
    request.headers['Authorization'] = auth;
  }

  ///Extracts json entity from a Map
  String _getJsonFromMap(Map<String,String> bodyMap){
    String body='{';
    for(String key in bodyMap.keys){
      String mainVal=bodyMap[key].runtimeType==String?'"${bodyMap[key]}"':bodyMap[key];
      body+='"$key":${mainVal},';
    }
    body=body.substring(0,body.length-1)+'}';
    return body;
  }

  /// Get Blob.
  Future<http.StreamedResponse> getBlob(String path) async {
    var request = http.Request('GET', uri(path: path));
    sign(request);
    return request.send();
  }

  /// Put Blob.
  ///
  /// `body` and `bodyBytes` are exclusive and mandatory.
  Future<void> putBlob(String path,
      {String body,
        Uint8List bodyBytes,
        String contentType,
        BlobType type = BlobType.BlockBlob}) async {
    var request = http.Request('PUT', uri(path: path));
    request.headers['x-ms-blob-type'] =
    type.toString() == 'BlobType.AppendBlob' ? 'AppendBlob' : 'BlockBlob';
    request.headers['content-type'] = contentType;
    if (type == BlobType.BlockBlob) {
      if (bodyBytes != null) {
        request.bodyBytes = bodyBytes;
      } else if (body != null) {
        request.body = body;
      }
    } else {
      request.body = '';
    }
    sign(request);
    var res = await request.send();
    if (res.statusCode == 201) {
      await res.stream.drain();
      if (type == BlobType.AppendBlob && (body != null || bodyBytes != null)) {
        await appendBlock(path, body: body, bodyBytes: bodyBytes);
      }
      return;
    }

    var message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  Future<void> deleteBlob(String path,
      {String body,
        Uint8List bodyBytes,
        String contentType,
        BlobType type = BlobType.BlockBlob}) async {
    var request = http.Request('DELETE', uri(path: path));
    request.headers['x-ms-blob-type'] =
    type.toString() == 'BlobType.AppendBlob' ? 'AppendBlob' : 'BlockBlob';
    request.headers['content-type'] = contentType;
    if (type == BlobType.BlockBlob) {
      if (bodyBytes != null) {
        request.bodyBytes = bodyBytes;
      } else if (body != null) {
        request.body = body;
      }
    } else {
      request.body = '';
    }
    sign(request);
    var res = await request.send();
    if (res.statusCode == 202) {

      return;
    }

    var message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Append block to blob.
  Future<void> appendBlock(String path,
      {String body, Uint8List bodyBytes}) async {
    var request = http.Request(
        'PUT', uri(path: path, queryParameters: {'comp': 'appendblock'}));
    if (bodyBytes != null) {
      request.bodyBytes = bodyBytes;
    } else if (body != null) {
      request.body = body;
    }
    sign(request);
    var res = await request.send();
    if (res.statusCode == 201) {
      await res.stream.drain();
      return;
    }

    var message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Create a new table
  ///
  /// 'tableName' is  mandatory.
  Future<bool> createTable(String tableName) async {

    String body = '{"TableName":"$tableName"}';
    String path='https://${config[AccountName]}.table.core.windows.net/Tables';
    var request = http.Request('POST', Uri.parse( path));
    request.headers['Accept'] = 'application/json;odata=nometadata';
    request.headers['Content-Type'] = 'application/json';
    request.headers['Content-Length'] = '${body.length}';
    request.body = body;
    sign4Tables(request);
    var res = await request.send();
    var message = await res.stream.bytesToString();//DEBUG
    if (res.statusCode ==201 || res.statusCode==204 ) {
//      await res.stream.drain();
      return true;
//      return 'ok:${res.statusCode}';
    }else if(res.statusCode==204){
      return false;
    }
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Delete a new table from azure storage account
  ///
  /// 'tableName' is  mandatory.
  Future<bool> deleteTable(String tableName) async {

    String path='https://${config[AccountName]}.table.core.windows.net/Tables(\'$tableName\')';
    var request = http.Request('DELETE', Uri.parse( path));
    request.headers['Accept'] = 'application/json;odata=nometadata';
    request.headers['Content-Type'] = 'application/json';
    sign4Tables(request);
    var res = await request.send();
    if (res.statusCode==204 ) {
      return true;
    }
    var message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Get a list of all tables in storage accout
  ///
  Future<List<String>> getTables() async {

    String path='https://${config[AccountName]}.table.core.windows.net/Tables';
    var request = http.Request('GET', Uri.parse( path));
    request.headers['Accept'] = 'application/json;odata=nometadata';
    request.headers['Content-Type'] = 'application/json';
    sign4Tables(request);
    var res = await request.send();
    var message = await res.stream.bytesToString();//DEBUG
    if (res.statusCode ==200) {
      List<String> tabList=[];
      var jsonResponse= await jsonDecode(message);
      for(var tData in jsonResponse['value']){
        tabList.add(tData['TableName']);
      }
      return tabList;
    }
//     message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Upload or update table entity/entry.
  ///
  /// 'tableName', `partitionKey` and `rowKey` are all mandatory. `body` and `bodyMap` are exclusive and mandatory.
  Future<String> upsertTableData(
      {String tableName,
        String partitionKey,
        String rowKey,
        String body,
        Map<String,dynamic> bodyMap}) async {

    if (bodyMap != null && bodyMap.length>0) {
      body = _getJsonFromMap(bodyMap);
    }
    String path='https://${config[AccountName]}.table.core.windows.net/$tableName(PartitionKey=\'$partitionKey\', RowKey=\'$rowKey\')';
    var request = http.Request('MERGE', Uri.parse( path));
    request.headers['Accept'] = 'application/json;odata=nometadata';
    request.headers['Content-Type'] = 'application/json';
    request.headers['Content-Length'] = '${body.length}';
    request.body = body;
    sign4Tables(request);
    var res = await request.send();
    if (res.statusCode >= 200 && res.statusCode<300) {
      await res.stream.drain();
      return 'ok:${res.statusCode}';
    }
    var message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Upload or replace table entity/entry.
  ///
  /// 'tableName',`partitionKey` and `rowKey` are all mandatory. `body` and `bodyMap` are exclusive and mandatory.
  Future<String> putTableData(
      {String tableName,
        String partitionKey,
        String rowKey,
        String body,
        Map<String,dynamic> bodyMap}) async {

    if (bodyMap != null && bodyMap.length>0) {
      body = _getJsonFromMap(bodyMap);
    }
    String path='https://${config[AccountName]}.table.core.windows.net/$tableName(PartitionKey=\'$partitionKey\', RowKey=\'$rowKey\')';
    var request = http.Request('PUT', Uri.parse( path));
    request.headers['Accept'] = 'application/json;odata=nometadata';
    request.headers['Content-Type'] = 'application/json';
    request.headers['Content-Length'] = '${body.length}';
    request.body = body;
    sign4Tables(request);
    var res = await request.send();
    if (res.statusCode >= 200 && res.statusCode<300) {
      await res.stream.drain();
      return 'ok:${res.statusCode}';
    }
    var message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// get data from azure tables
  ///
  /// 'tableName','partitionKey' and 'rowKey' are all mandatory. If no fields are specified, all fields attached to the entry are returned
  Future<String> getTableData(
      {
        String tableName,
        String partitionKey,
        String rowKey,
        List<String> fields}) async {

    String selectParams='*';
    if(fields!=null && fields.length>0) {
      for (String s in fields) {
        selectParams += ',$s';
      }
    }
    String path='https://${config[AccountName]}.table.core.windows.net/$tableName(PartitionKey=\'$partitionKey\', RowKey=\'$rowKey\')?select=${selectParams.substring(1)}';
    var request = http.Request('GET', Uri.parse( path));
    request.headers['Accept'] = 'application/json;odata=nometadata';
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept-Charset'] = 'UTF-8';
    request.headers['DataServiceVersion'] = '1.0;NetFx';
    request.headers['MaxDataServiceVersion'] = '3.0;NetFx';
    sign4Tables(request);
    var res = await request.send();
    if (res.statusCode >= 200 && res.statusCode<300) {
      var message = await res.stream.bytesToString();
      return message;
    }
    var message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }


  /// Delete table entity.
  ///
  ///  'tableName', `partitionKey` and `rowKey` are all mandatory.
  Future<String> deleteTableData(
      {String tableName,
        String partitionKey,
        String rowKey}) async {

    String path='https://${config[AccountName]}.table.core.windows.net/$tableName(PartitionKey=\'$partitionKey\', RowKey=\'$rowKey\')';
    var request = http.Request('DELETE', Uri.parse( path));
    request.headers['Accept'] = 'application/json;odata=nometadata';
    request.headers['Content-Type'] = 'application/json';
    sign4Tables(request);
    var res = await request.send();
    if (res.statusCode >= 200 && res.statusCode<300) {
      await res.stream.drain();
      return 'ok:${res.statusCode}';
    }
    var message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Create a new queue
  ///
  /// 'qName' is  mandatory.
  Future<bool> createQueue(String qName) async {

    String path='https://${config[AccountName]}.queue.core.windows.net/$qName';
    var request = http.Request('PUT', Uri.parse( path));
    request.headers['Content-Type'] = 'application/json';
    sign(request);
    var res = await request.send();
    if (res.statusCode ==201) {
      return true;
    }
    var message = await res.stream.bytesToString();//DEBUG
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Create a new queue
  ///
  /// 'qName' is  mandatory.
  Future<List<String>> getQList() async {

    String path='https://${config[AccountName]}.queue.core.windows.net?comp=list';
    var request = http.Request('GET', Uri.parse( path));
    request.headers['Content-Type'] = 'application/json';
    sign4Q(request);
    var res = await request.send();
    var message = await res.stream.bytesToString();//DEBUG
    print('Get queue result ${message}');
    if (res.statusCode ==200) {
      List<String> tabList=[];
//      var jsonResponse= await jsonDecode(message);
      var resDoc= XmlDocument.parse(message);

      for(var tData in resDoc.['value']){
        tabList.add(tData['TableName']);
      }
      return tabList;
    }
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

}

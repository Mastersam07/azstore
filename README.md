# azstore

Access azure storage options via REST APIs.

## Getting Started

This package handles all the encryption and formatting required to provide easy access to azure storage options via REST APIs.
The package currently provides functions to query and upload data to Azure blobs, tables and queues. Add the latest dependency to your
pubspec.yaml to get started.        ```azstore: ^0.0.1 ```          and import.Tn the following examples,         `'your connection string'`
 can be gotten from the azure portal.

## Azure Blob Functions.

Upload file to blob with         `putBlob`         function.         `body`          and         `bodyBytes`         are exclusive and mandatory.

Example:

```
Future<void> testUploadImage() async {
  File testFile =File('C:/Users/HP/Pictures/fdblack.png');
  Uint8List bytes = testFile.readAsBytesSync();
  var storage = AzureStorage.parse('your connection string');
  try {
    await storage.putBlob('/azpics/fdblack.png',
      bodyBytes: bytes,
      contentType: 'image/png',
    );
  }catch(e){
    print('exception: $e');
  }
}
```

Text can also be uploaded to blob in which case         `body`         parameter is specified instead of         `bodyBytes`         .

Delete blob operations can also be performed as shown.

```
Future<void> testDeleteBlob() async {
  var storage = AzureStorage.parse('your connection string');
  try {
    await storage.deleteBlob('/azpics/fdblack.png');
    print('done deleting');//Do something else
  }catch(e){
    print('exception: $e');
  }
}
```

Also explore the         `appendBlock`          function.

## Table Storage Functions

The Azure Table service offers structured NoSQL storage in the form of tables.
Tables can be managed using the         `createTable`,`deleteTable`         and         `getTables`          functions.
Table nodes/rows can be controlled using other functions  such as         `upsertTableRow`,`putTableRow`,`getTableRow` and `deleteTableRow`.

The following snippets show the use of some handy table functions. Also refer to the [Azure Tables docs](https://docs.microsoft.com/en-us/rest/api/storageservices/payload-format-for-table-service-operations/) for allowed data types to insert in a table row.
The code documentation provides further help.

```
Future<void> testUpload2Table() async {
  var storage = AzureStorage.parse('your connection string');
  try {
    var myPartitionKey=generateUniqueKey();
    var myRowKey='237';
    Map<String, dynamic> rowMap={"Address":"Santa Clara",
    "Age":23,
    "AmountDue":200.23,
    "CustomerCode@odata.type":"Edm.Guid",
    "CustomerCode":"c9da6455-213d-42c9-9a79-3e9149a57833",
    "CustomerSince@odata.type":"Edm.DateTime",
     "CustomerSince":"2008-07-10T00:00:00",
     "IsActive":false,
     "NumberOfOrders@odata.type":"Edm.Int64",
     "NumberOfOrders":"255",
     "PartitionKey":"$myPartitionKey",
     "RowKey":"$myRowKey"
    };
    await storage.upsertTableRow(
        tableName: 'profiles',
        rowKey:myRowKey,
        bodyMap: rowMap
     );
  }catch(e){
    print('tables upsert exception: $e');
  }
}


```
This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

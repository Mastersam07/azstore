import 'package:azstore/src/azstore_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azstore/azstore.dart';
import 'package:xml/xml.dart';

Future<void> main() async {
  test('adds one to input values', () {


  });



//  String str2='''<?xml version="1.0" encoding="utf-8"?>
//<EnumerationResults ServiceEndpoint="https://myaccount.queue.core.windows.net/">
//  <Prefix>q</Prefix>
//  <MaxResults>3</MaxResults>
//  <Queues>
//    <Queue>
//      <Name>q1</Name>
//      <Metadata>
//        <Color>red</Color>
//        <SomeMetadataName>SomeMetadataValue</SomeMetadataName>
//      </Metadata>
//    </Queue>
//    <Queue>
//      <Name>q2</Name>
//      <Metadata>
//        <Color>blue</Color>
//        <SomeMetadataName>SomeMetadataValue</SomeMetadataName>
//      </Metadata>
//    </Queue>
//    <Queue>
//      <Name>q3</Name>
//      <Metadata>
//        <Color>yellow</Color>
//        <SomeMetadataName>SomeMetadataValue</SomeMetadataName>
//      </Metadata>
//    </Queue>
//  </Queues>
//  <NextMarker>q4</NextMarker>
//</EnumerationResults>''';
//  String str2='''<QueueMessage><MessageId>0e0cdab1-ad8e-4f6f-b5f4-215dc3f2db4c</MessageId><InsertionTime>Tue, 23 Mar 2021 03:01:00 GMT</InsertionTime><ExpirationTime>Tue, 30 Mar 2021 03:01:00 GMT</ExpirationTime><PopReceipt>AgAAAAMAAAAAAAAAODaUPJkf1wE=</PopReceipt><TimeNextVisible>Tue, 23 Mar 2021 04:01:43 GMT</TimeNextVisible><DequeueCount>9</DequeueCount><MessageText>yo whats up</MessageText></QueueMessage>''';
//
//  XmlDocument xx= XmlDocument.parse(str2);
//  print(xx.getElement('QueueMessage').getElement('MessageId').text);
//  for (var qNode in xx.getElement('QueueMessagesList').nodes){
////    qNode.normalize();
////    String name=qNode.text;
//  if(qNode==null||qNode.getElement('MessageId')==null) continue;
//    print('${ qNode.getElement('MessageId').text}');
//  }
//  await testDeleteQ();
//  await testQs();
//  await testCreateQ();
//  await testGetQData();
//  await testPutMessage();
//  await testGetQMessages();
  await testPeekQMessages();
}



Future<void> testPutMessage() async {
  var storage = AzureStorage.parse('DefaultEndpointsProtocol=https;AccountName=gmartstore;AccountKey=63mnWYO7EfsBzwevWKfozxHqEJ5XrFJyJdR9e10vtlE4pfvcybBbIAmoBWKtkj9vNhqSwtPDF3K1OWtzXhh/Wg==;EndpointSuffix=core.windows.net');
  print('working on results...');
  try {
    bool result = await storage.putQMessage('ttable', message: 'yo whats up');
    print('showing results $result');
  }catch(e){
    print('get data error: ${e.statusCode} ${e.message}');
  }
}


Future<void> testGetQData() async {
  var storage = AzureStorage.parse('DefaultEndpointsProtocol=https;AccountName=gmartstore;AccountKey=63mnWYO7EfsBzwevWKfozxHqEJ5XrFJyJdR9e10vtlE4pfvcybBbIAmoBWKtkj9vNhqSwtPDF3K1OWtzXhh/Wg==;EndpointSuffix=core.windows.net');
  print('working on results...');
  try {
    Map<String, String> result = await storage.getQData('ttable');
    print('showing results');
    for (var res in result.entries) {
      print('${res.key}: ${res.value}');
    }
  }catch(e){
    print('get data error: ${e.statusCode} ${e.message}');
  }
}

Future<void> testDeleteQ() async {
  var storage = AzureStorage.parse('DefaultEndpointsProtocol=https;AccountName=gmartstore;AccountKey=63mnWYO7EfsBzwevWKfozxHqEJ5XrFJyJdR9e10vtlE4pfvcybBbIAmoBWKtkj9vNhqSwtPDF3K1OWtzXhh/Wg==;EndpointSuffix=core.windows.net');
  print('working on results...');
  bool createQ=await storage.deleteQueue('newer-queue');
  print('delete result $createQ');
}

Future<void> testCreateQ() async {
  var storage = AzureStorage.parse('DefaultEndpointsProtocol=https;AccountName=gmartstore;AccountKey=63mnWYO7EfsBzwevWKfozxHqEJ5XrFJyJdR9e10vtlE4pfvcybBbIAmoBWKtkj9vNhqSwtPDF3K1OWtzXhh/Wg==;EndpointSuffix=core.windows.net');
  print('working on results...');
  bool createQ=await storage.createQueue('newer-queue');
  print('create result $createQ');
}

Future<void> testGetQMessages() async {
  var storage = AzureStorage.parse('DefaultEndpointsProtocol=https;AccountName=gmartstore;AccountKey=63mnWYO7EfsBzwevWKfozxHqEJ5XrFJyJdR9e10vtlE4pfvcybBbIAmoBWKtkj9vNhqSwtPDF3K1OWtzXhh/Wg==;EndpointSuffix=core.windows.net');
  print('working on results...');
  try {
    List<AzureQMessage> result = await storage.getQmessages('ttable');
    print('showing results');
    for (var res in result) {
      print('message ${res.messageText}');
    }
  }catch (e){
    print('get messages exception ${e.toString()}');
  }
}


Future<void> testPeekQMessages() async {
  var storage = AzureStorage.parse('DefaultEndpointsProtocol=https;AccountName=gmartstore;AccountKey=63mnWYO7EfsBzwevWKfozxHqEJ5XrFJyJdR9e10vtlE4pfvcybBbIAmoBWKtkj9vNhqSwtPDF3K1OWtzXhh/Wg==;EndpointSuffix=core.windows.net');
  print('working on results...');
  try {
    List<AzureQMessage> result = await storage.peekQmessages('ttable');
    print('showing results');
    for (var res in result) {
      print('message ${res.messageText}');
    }
  }catch (e){
    print('peek messages exception ${e.toString()}');
  }
}

Future<void> testQs() async {
  var storage = AzureStorage.parse('DefaultEndpointsProtocol=https;AccountName=gmartstore;AccountKey=63mnWYO7EfsBzwevWKfozxHqEJ5XrFJyJdR9e10vtlE4pfvcybBbIAmoBWKtkj9vNhqSwtPDF3K1OWtzXhh/Wg==;EndpointSuffix=core.windows.net');
  print('working on results...');
  List<String> result=await storage.getQList();
  print('showing results');
  for(String res in result){
    print(res);
  }
}

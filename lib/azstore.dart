library azstore;

import 'package:xml/xml.dart';


void main(){
  XmlDocument xx= XmlDocument.parse('''<?xml version="1.0" encoding="utf-8"?>  
<EnumerationResults ServiceEndpoint="https://myaccount.queue.core.windows.net/">  
  <Prefix>string-value</Prefix>  
  <Marker>string-value</Marker>  
  <MaxResults>int-value</MaxResults>  
  <Queues>  
    <Queue>  
      <Name>string-value</Name>  
      <Metadata>  
      <metadata-name>value</metadata-name>  
    <Metadata>  
    </Queue>  
  <NextMarker />  
</EnumerationResults>  ''');
  for (var qNode in xx.getElement('Queues').children){
    String name=qNode.getElement('Name').text;
    print(name);
  }

}
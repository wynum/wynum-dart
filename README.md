# Installation
```yaml
dependencies:
  wynum_client:
```

# Getting started
Very easy to use. Create a ```Client``` and you're ready to go.
## API Credentials
The ```Client``` needs Wynum credentials.You can either pass these directly to the constructor.
```dart
import 'package:wynum_client/wynum_client.dart';

String secret = "your_secret_key"
String token = "project_token"
final client = Client.create(secret: secret, token: token)
```

## Get schema
call ```getSchema``` on ```Client``` to get the keys and types for the data. This will return a ```List``` of ```Schema``` objects.  ```Schema.key``` will return the key and ```Schema.type``` will return the Wynum type. Following is the mapping from Wynum type to dart type.

| Wynum type            | Dart type              |
| --------------------- | ------------------------ |
| Text                  | ```String```                |
| Date                  | ```String``` (dd/mm/yyyy)   |
| Number                | ```int``` or ```double``` |
| Choice (Or)           | ```int``` or ```double``` |
| Multiple Choice (And) | ```List``` of ```String```  |
| Time                  | ```String``` (hh:mm)        |
| File                  | ```File```               |

```dart
final schemas = await client.getSchema()
for (var schema in schemas) {
  print(schema);
}
```

## Post data
the ```postData``` method accepts a single parameter data which is a ```Map``` containing the post key:value. Every data ```Map``` should contain the 'identifier'. You can get identifier key if you have called ```getSchema```. You can retrieve it using ```client.identifier```.

```dart
await client.getSchema()
String identifierKey = client.identifier
Map data = {'key1':val1, 'key2':val2, identifierKey:'id_string'}
final res = await client.postData(data)
```
If the call is successful it returns the ```Map``` containing the created data instance. If there is some error the ```Map``` will contain ```_error``` and ```_message``` keys.  You should check this to check for errors.

## Get data
Call ```getData``` to get the data. This will return ```List``` of ```Map```
```dart
final data = await client.getData()
```

## Updating data
The ```update``` method is same as that of ```postData``` method.
```dart
await client.getSchema()
String identifierKey = client.identifier
Map data = {'key1':val1, 'key2':val2, identifierKey:'id_string'}
final res = await client.update(data)
```
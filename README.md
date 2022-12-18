# supabase_extensions

supabase_extensions is an extension library to the [Supabase](https://supabase.com/) API

## Features
* Writing raw sql statement to the supabase (uses postgrest behind the scenes)

**Note**: Select statement only  

## Getting started
For using it on your app:

```dart
import 'package:supabase_extensions/base.dart';
```

For API reference [check here](https://pub.dartlang.org/documentation/supabase_extensions/latest/)

## Usage

```dart
// init Supabase Client..
// final supabase = SupabaseClient('supabaseUrl', 'supabaseKey');

const sqlString = 'SELECT code FROM courses WHERE code > 32000 ORDER BY code LIMIT 2';
List<Map<String, dynamic>> results = await supabase.sql(sqlString);
```

## Additional information

Based heavily on the [Postgrest API](https://postgrest.org/en/stable/api.html) 

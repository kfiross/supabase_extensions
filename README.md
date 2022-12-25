# supabase_extensions

supabase_extensions is an extension library to the [Supabase](https://supabase.com/) API

## Features
* Using SQL statement strings to get results from Supabase (uses PostgREST behind the scenes)
* Shorter syntax 

**Note**: Select/Insert statement only (WIP)  

## Getting started
For using it on your app:

```dart
import 'package:supabase_extensions/base.dart';
```

For API reference [check here](https://pub.dartlang.org/documentation/supabase_extensions/latest/)

## Usage

### SupabaseClient.sql(String rawQuery)
Fetching data using raw queries' strings using Supabase's database (Postgres)
```dart
// init Supabase Client..
// final supabase = SupabaseClient('supabaseUrl', 'supabaseKey');

const sqlString = 'SELECT code FROM courses WHERE code > 32000 ORDER BY code LIMIT 2';
QueryResults queryResults = await supabase.sql(sqlString);

List<Map<String, dynamic>> results = queryResults.results;
```

### SupabaseClient.uid
Get the user's ID (if exist) easily
```dart
// init Supabase Client..
// final supabase = SupabaseClient('supabaseUrl', 'supabaseKey');

String? userId = supabase.uid;  /// instead supabase.auth.currentUser?.id
```

## Additional information

Based heavily on the [Postgrest API](https://postgrest.org/en/stable/api.html) 

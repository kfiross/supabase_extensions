# supabase_extensions

supabase_extensions is a couple of extensions to the [Supabase](https://supabase.com/) API

## Features
* Using SQL statement strings to get results from Supabase (uses PostgREST behind the scenes)
* Shorter syntax when possible
* Simpler way to listen to changes in the Database

**Note**: only Select/Insert SQL statement are supported (WIP)  

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

List<Map<String, dynamic>> rows = queryResults.rows;
```

### SupabaseClient.uid
Get the user's ID (if exist) easily
```dart
// init Supabase Client..
// final supabase = SupabaseClient('supabaseUrl', 'supabaseKey');

String? userId = supabase.uid;  /// instead supabase.auth.currentUser?.id
```

### Supabase.isLogged
Get if the user already logged in or not
```dart
// init Supabase Client..
// final supabase = SupabaseClient('supabaseUrl', 'supabaseKey');

bool isLoggedIn = supabase.isLogged;  /// instead supabase.auth.currentUser?.id != null
```

### Supabase.jwt
Get the user's current session access token (if the user already logged in)
```dart
// init Supabase Client..
// final supabase = SupabaseClient('supabaseUrl', 'supabaseKey');

String? accessToken = supabase.jwt;  /// instead supabase.auth.currentSession?.accessToken
```



### Supabase.on(String table, CrudEvent eventType)

```dart
// init Supabase Client..
// final supabase = SupabaseClient('supabaseUrl', 'supabaseKey');

// Regular way
supabase.from('test').stream(primaryKey: ['id']).listen((event) {
    print(event);
});
```
You can listen to only single event type (`'INSERT'`,`'UPDATE'` or `'DELETE'`)
```dart
// any event in table 'test'
supabase.on('table').listen((event) {
print(event);
});

// only INSERT events in table 'test'
supabase.on('table', CrudEvent.insert).listen((event) {
    print(event);
});

// shorter syntax for only INSERT, DELETE
supabase.onInsert('table').listen((event) {
  print(event);
});
supabase.onDelete('table').listen((event) {
  print(event);
});
```

!! Remember to remove the channels and to close streams when you're done
```dart
supabase.removeAllChannels();
supabase.closeAllStreams();   // ADD THIS TOO!
```

### SupabaseAuth extensions

#### auth.provider()
Return the name of the provider the user is logged to ('apple', 'google'..)
```dart
String? providerName = supabase.auth.provider; /// instead supabase.auth.provider
```

## Additional information

Based heavily on the [Postgrest API](https://postgrest.org/en/stable/api.html) 

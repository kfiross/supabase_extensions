import 'package:supabase/supabase.dart';
import 'package:supabase_extensions/src/base.dart';
import 'package:supabase_extensions/src/query_results.dart';
import 'package:dotenv/dotenv.dart';
import 'package:supabase_extensions/src/supabase_auth_ext.dart';

void main() async {
  // init Supabase Client..
  var env = DotEnv(includePlatformEnvironment: true)..load();
  final String SUPABASE_URL = env['SUPABASE_URL']!;
  final String SUPABASE_ANNON_KEY = env['SUPABASE_ANNON_KEY']!;

  final supabase = SupabaseClient(SUPABASE_URL, SUPABASE_ANNON_KEY);

  // final userID = supabase.uid;
  var userId = "dcde0dba-f759-4700-84a2-5534aadaaf54";
  //var results = await supabase.sql("select * from user_constraints where user_id = '$u'");
  //print(results.rows ?? []);

  var results = await supabase
      .sql("select * from user_constraints where user_id = '$userId'");
  print(results.rows ?? []);


  final providerName = supabase.auth.provider;

  // supabase.auth.onAuthStateChange.listen((authState) {
  //   if (authState.event == AuthChangeEvent.signedOut) {
  //     // go to login screen automagically
  //   }
  // });

  //
  supabase.from('test').stream(primaryKey: ['id']).listen((event) {
    print(event);
  });

  supabase.on('test', CrudEvent.insert).listen((event) {
    print(event);
  });

  supabase.onInsert('test').listen((event) {
    print(event);
  });

  // remember to remove the channels when you're done
  supabase.removeAllChannels();
  supabase.closeAllStreams();

  //
  // var _schema = 'public';
  // var _table = 'test';
  // var _incrementId = 12;
  // var channel = supabase.realtime.channel('$_schema:$_table:$_incrementId');
  //
  // channel.on(RealtimeListenTypes.postgresChanges,
  //     ChannelFilter(event: 'DELETE',  table: 'test',), (payload, [ref]) {
  //       print('channel delete payload: $payload');
  //     });
  // channel.on(RealtimeListenTypes.postgresChanges,
  //     ChannelFilter(event: 'INSERT',  table: 'test',), (payload, [ref]) {
  //       print('channel insert payload: $payload');
  //     });
  // //
  // supabase.realtime.onMessage((message) => print('MESSAGE $message'));
  // supabase.realtime.connect();
  // channel.subscribe((a, [_]) => print('SUBSCRIBED'));

  await Future.delayed(Duration(seconds: 100));

  // supabase.deleteFolder(bucketId, folderPath);
  // storage.from(bucketId).remove([folderPath]);

  // const sqlString =
  //   'SELECT * FROM plan WHERE department_id = 1';
  // List<Map<String, dynamic>> results = await supabase.sql(sqlString);

  //
  QueryResults data = await supabase.sql(
      "select last_data from saved_schedules where user_id = '6bce5d00-5365-4d44-a33b-089ee431161b'");
  // print(data.rows);

  // supabase.from('app_counters').update({'value': 6}, options: FetchOptions(forceResponse: true))
  //     .eq('type', 'app_visits');
  // final sqlInsertString = "INSERT INTO app_counters (type, value) VALUES ('kuku', 6)";// WHERE type = 'app_visits'";
  // var results = await supabase.sql(sqlInsertString);
  // print(results);
}

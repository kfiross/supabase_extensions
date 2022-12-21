import 'package:supabase/supabase.dart';
import 'package:supabase_extensions/supabase_extensions.dart';

void main() async {
  // init Supabase Client..


  final supabase = SupabaseClient(SUPABASE_URL, SUPABASE_ANNON_KEY);

  const sqlString =
    'SELECT * FROM plan WHERE department_id = 1';
  List<Map<String, dynamic>> results = await supabase.sql(sqlString);
  print(results);


  // supabase.from('app_counters').update({'value': 6}, options: FetchOptions(forceResponse: true))
  //     .eq('type', 'app_visits');
  // final sqlInsertString = "INSERT INTO app_counters (type, value) VALUES ('kuku', 6)";// WHERE type = 'app_visits'";
  // var results = await supabase.sql(sqlInsertString);
  // print(results);


}

import 'package:supabase/supabase.dart';
import 'package:supabase_extensions/supabase_extensions.dart';

void main() async {
  // init Supabase Client..
  final supabase = SupabaseClient('supabaseUrl', 'supabaseKey');

  const sqlString = 'SELECT code FROM courses WHERE code > 32000 ORDER BY code LIMIT 2';
  List<Map<String, dynamic>> results = await supabase.sql(sqlString);
  print(results);
}

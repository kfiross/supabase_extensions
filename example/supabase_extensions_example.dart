import 'package:supabase/supabase.dart';
import 'package:supabase_extensions/supabase_extensions.dart';

void main() async {
  // init Supabase Client..

  const SUPABASE_URL = "https://rbwvyxnhamichywqgjqb.supabase.co";
  const SUPABASE_ANNON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJid3Z5eG5oYW1pY2h5d3FnanFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NTU1NzcwNDcsImV4cCI6MTk3MTE1MzA0N30.CRalEPItZFPIRyGNz2_pmbALRHK1KMNVzejUsW_GnZY";

  final supabase = SupabaseClient(SUPABASE_URL, SUPABASE_ANNON_KEY);

  const sqlString =
    'SELECT * FROM plan WHERE department_id = 1';
    //  'select distinct year, semester from classes where real_year = 5783 and department = 1 and track = 1 order by semester, year';
      //'select distinct(classes.code), name, department, semester, is_online from classes, courses where classes.code = courses.code and department = $department and track = $track order by classes.code'
  //     // 'SELECT code FROM courses WHERE code > 32000 ORDER BY code LIMIT 2';
  List<Map<String, dynamic>> results = await supabase.sql(sqlString);
  print(results);



}

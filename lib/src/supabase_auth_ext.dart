import 'package:supabase/supabase.dart';

extension SupabaseAuthX on GoTrueClient {
  String get provider {
    return currentUser?.appMetadata['provider'];
  }
}

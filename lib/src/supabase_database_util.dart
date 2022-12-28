import 'dart:async';

import 'package:supabase/supabase.dart';

var _incrementId = 1;

class SupabaseDatabase {
  final SupabaseClient supabaseClient;

  SupabaseDatabase._(this.supabaseClient);

  static SupabaseDatabase getInstance(SupabaseClient supabaseClient) =>
      SupabaseDatabase._(supabaseClient);

  final Map<String, StreamController> _streams = {};

  Future<void> closeAllStream(){
    return Future.wait(_streams.values.map((stream) => stream.close()));
  }

  Stream<dynamic> onTableChanged(String table, {String? event}) {
    final streamController = StreamController.broadcast();
    var realtimeTopic = 'public:$table:$_incrementId';

    _streams['channel_$realtimeTopic'] = streamController;

    _incrementId++;
    var channel = supabaseClient.realtime.channel(realtimeTopic);
    channel.on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(event: event ?? '*', schema: 'public', table: table), (
        payload,
        [ref]) {
      _onEventHandler(payload, streamController);
    }).subscribe();

    return streamController.stream;
  }

  void _onEventHandler(payload, StreamController streamController) {
    String eventType = payload['eventType'];
    switch (eventType) {
      case "INSERT":
        final newRecord = Map<String, dynamic>.from(payload['new']!);
        streamController.add(newRecord);
        break;

      case "UPDATE":
        final newRecord = Map<String, dynamic>.from(payload['new']!);
        streamController.add(newRecord);
        break;

      case "DELETE":
        break;
    }
  }
}

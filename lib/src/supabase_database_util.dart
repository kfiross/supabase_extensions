import 'dart:async';

import 'package:supabase/supabase.dart';

import 'base.dart';

var _incrementId = 1;

class SupabaseDatabase {
  final SupabaseClient supabaseClient;

  SupabaseDatabase._(this.supabaseClient);

  static SupabaseDatabase getInstance(SupabaseClient supabaseClient) =>
      SupabaseDatabase._(supabaseClient);

  final Map<String, StreamController> _streams = {};

  /// Closes all the open stream done with listening to table changes
  Future<void> closeAllStream() {
    return Future.wait(_streams.values.map((stream) => stream.close()));
  }

  /// Returns a stream that listen to changes when [event] occurred in [table]
  Stream<dynamic> onTableChanged(String table, {CrudEvent? event}) {
    final streamController = StreamController.broadcast();
    final String realtimeTopic = 'public:$table:$_incrementId';

    _streams['channel_$realtimeTopic'] = streamController;

    _incrementId++;

    PostgresChangeEvent postgresChangeEvent = PostgresChangeEvent.all;
    if(event != null){
      switch(event){
        case CrudEvent.insert:
          postgresChangeEvent = PostgresChangeEvent.insert;
        case CrudEvent.update:
          postgresChangeEvent = PostgresChangeEvent.update;
        case CrudEvent.delete:
          postgresChangeEvent = PostgresChangeEvent.delete;
      }
    }

    var channel = supabaseClient.realtime.channel(realtimeTopic);
    channel.onPostgresChanges(
        event: postgresChangeEvent,
        table: table,
        schema: 'public',
        callback: (payload) => _onEventHandler(payload, streamController),
    ).subscribe();


    return streamController.stream;
  }

  void _onEventHandler(PostgresChangePayload payload, StreamController streamController) {
    PostgresChangeEvent eventType = payload.eventType;
    switch (eventType) {
      case PostgresChangeEvent.insert:
        final newRecord = payload.newRecord;
        streamController.add(newRecord);
        break;

      case PostgresChangeEvent.update:
        final newRecord = payload.newRecord;
        streamController.add(newRecord);
        break;

      // TODO: need to check
      case PostgresChangeEvent.delete:
        final newRecord = payload.newRecord;
        streamController.add(newRecord);
        break;

      case PostgresChangeEvent.all:
        break;
    }
  }
}

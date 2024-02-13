import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sqlparser/sqlparser.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_extensions/src/query_results.dart';
import 'list_ext.dart';
import 'supabase_database_util.dart';

enum CrudEvent { insert, update, delete }

extension SupabaseExtensions on SupabaseClient {
  SupabaseDatabase get _database => SupabaseDatabase.getInstance(this);

  String get supabaseRestUrl => rest.url;

  String get supabaseKey => rest.headers['apiKey'] ?? '';


  /// Returns current user id (user has logged in )
  String? get uid => auth.currentUser?.id;

  /// Returns if user has logged in or not
  bool get isLogged => uid != null;

  /// Return jwt (accessToken) of current session
  String? get jwt => auth.currentSession?.accessToken;

  // Map<String, dynamic> get userMetadata => auth.currentUser?.userMetadata ?? {};

  /// Executing a given [SelectStatement] statement and returns the rows
  Future<QueryResults> _performSelect(SelectStatement statement) async {
    // Extract the table name, column names, and WHERE clause from the statement
    String tableName = (statement.table!.first as IdentifierToken).identifier;

    List<String> columnNames = [];
    for (var column in statement.columns) {
      columnNames.add(column.first.toString().split(':')[1].trim());
    }
    String whereClause = "";
    if (statement.where != null) {
      whereClause = statement.where.toString().split(':')[1].trim();
      whereClause = whereClause.replaceAll('and', 'AND');

      // Split the WHERE clause into individual conditions
      final conditions = whereClause.split(' AND ');

      // Create a list of maps representing the conditions
      final whereArgs = conditions.map((c) {
        final parts = c.split(' ');
        final column = parts[0];
        final operator = parts[1];
        final value = parts[2];

        // Convert the SQL operator to the corresponding PostgREST operator
        String postgrestOperator = "";
        switch (operator) {
          case '=':
            postgrestOperator = 'eq.';
            break;
          case '>':
            postgrestOperator = 'gt.';
            break;
          case '>=':
            postgrestOperator = 'gte.';
            break;
          case '<':
            postgrestOperator = 'lt.';
            break;
          case '<=':
            postgrestOperator = 'lte.';
            break;
          // TODO: TEST
          case 'LIKE':
            postgrestOperator = 'like';
            break;
          // TODO: TEST
          case 'IN':
            postgrestOperator = 'in';
            break;
        }

        return {
          'column': column,
          'operator': postgrestOperator,
          'value': value.replaceAll("'", ""),
        };
      });

      whereClause = whereArgs
          .map((arg) => '${arg['column']}=${arg['operator']}${arg['value']}')
          .join('&');
    }
    var orderbyClauses = <String>[];
    if (statement.orderBy != null) {
      var orderingTerms =
          statement.orderBy!.childNodes.map((e) => e as OrderingTerm);
      for (var term in orderingTerms) {
        var field = "${term.expression}";
        var ordering =
            term.orderingMode != OrderingMode.descending ? 'asc' : 'desc';
        orderbyClauses.add("$field.$ordering");
      }
    }


    // Build the URL with query parameters
    String url = "$supabaseRestUrl/$tableName?";
    if (columnNames.isNotEmpty) {
      url += "select=${Uri.encodeQueryComponent(columnNames.join(","))}";
    }
    if (whereClause.isNotEmpty) {
      url += "&$whereClause";
    }
    if (statement.orderBy != null) {
      url += "&order=${orderbyClauses.join(',')}";
    }
    if (statement.limit != null) {
      url +=
          "&limit=${(statement.limit! as Limit).count.toString().split('value ')[1]}";
    }

    // GET https://rbwvyxnhamichywqgjqb.supabase.co/rest/v1/courses?code=eq.90023 ??

    // Create a GET request to the URL
    http.Response response = await http.get(Uri.parse(url), headers: {
      'apikey': supabaseKey,
    });

    final data = json.decode(response.body);

    if (response.statusCode >= 500) {
      throw Exception("PostgREST Error");
    }
    if (response.statusCode > 400) {
      throw Exception("SQL Error (code ${data['code']}): ${data['message']}");
    } else if (response.statusCode == 400) {
      throw Exception(
          "Incorrect SQL statement (code ${data['code']}): ${data['message']}");
    }

    List<Map<String, dynamic>> results = data.cast<Map<String, dynamic>>();

    // "Distinct" trick on the list:
    if (statement.distinct) {
      results = results.distinct();
    }
    return QueryResults(rows: results);
  }

  Future<QueryResults> _sqlToDartOld(String sql) async {
    sql = sql.replaceAll('where', 'WHERE');
    sql = sql.replaceAll('from', 'FROM');

    // Extract the table name and the WHERE clause from the SQL query
    final regex = RegExp(r'FROM (\w+) WHERE (.*)');
    final match = regex.firstMatch(sql);
    final table = match!.group(1);
    final whereClause = match.group(2);

    // Split the WHERE clause into individual conditions
    final conditions = whereClause?.split(' AND ') ?? [];

    // Create a list of maps representing the conditions
    final whereArgs = conditions.map((c) {
      final parts = c.split(' ');
      final column = parts[0];
      final operator = parts[1];
      final value = parts[2];

      // Convert the SQL operator to the corresponding Dart operator
      String postgrestOperator = "";
      switch (operator) {
        case '>':
          postgrestOperator = 'gt.';
          break;
        case '<':
          postgrestOperator = 'lt.';
          break;
        case '=':
          postgrestOperator = 'eq.';
          break;
        // Add other cases as needed
      }

      return {
        'column': column,
        'operator': postgrestOperator,
        'value': value,
      };
    });

    final url =
        '$supabaseRestUrl/$table?${whereArgs.map((arg) => '${arg['column']}=${arg['operator']}${arg['value']}').join('&')}';
    final response = await http.get(Uri.parse(url), headers: {
      'apikey': supabaseKey,
    });
    final data = json.decode(response.body);
    if (response.statusCode >= 500) {
      throw Exception("PostgREST Error");
    }
    if (response.statusCode > 400) {
      throw Exception("SQL Error (code ${data['code']}): ${data['message']}");
    } else if (response.statusCode == 400) {
      throw Exception(
          "Incorrect SQL statement (code ${data['code']}): ${data['message']}");
    }
    List<Map<String, dynamic>> results = data.cast<Map<String, dynamic>>();
    return QueryResults(rows: results);
  }

  /// Executing a given [InsertStatement] statement and returns the rows
  Future<QueryResults> _performInsert(InsertStatement statement) async {
    // Extract the table name, column names, values, and WHERE clause from the statement
    String tableName = (statement.table.first as IdentifierToken).identifier;
    List<String> columnNames = [];
    for (var column in statement.targetColumns) {
      columnNames.add(column.columnName);
    }

    List<dynamic> values = [];
    var valuesExpressions =
        (statement.source.childNodes.first as Tuple).expressions;
    for (var exp in valuesExpressions) {
      values.add((exp as Literal).value);
    }

    // Build the URL with query parameters
    String url = "$supabaseRestUrl/$tableName";
    String data = "";
    for (int i = 0; i < columnNames.length; i++) {
      if (i > 0) {
        data += '&';
      }
      data += '${columnNames[i]}=${values[i]}';
    }

    // Create a POST request to the URL
    http.Response response =
        await http.post(Uri.parse(url), body: data, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'apikey': supabaseKey,
    });

    if (response.statusCode >= 400) {
      throw Exception(response.body);
    }

    return QueryResults();
  }

  /// Executing a given [DeleteStatement] statement and returns the rows
  Future<QueryResults> _performDelete(DeleteStatement statement) async {
    String tableName = (statement.table.first as IdentifierToken).identifier;

    // Build the URL with query parameters
    String url = "$supabaseRestUrl/$tableName";

    print("DELETE $url");

    String whereClause = "";
    final filterCondition = {};
    if (statement.where != null) {
      whereClause = statement.where.toString().split(':')[1].trim();
      whereClause = whereClause.replaceAll('and', 'AND');

      // Split the WHERE clause into individual conditions
      final conditions = whereClause.split(' AND ');

      // Create a list of maps representing the conditions
      final whereArgs = conditions.map((c) {
        final parts = c.split(' ');
        final column = parts[0];
        final operator = parts[1];
        final value = parts[2];

        // Convert the SQL operator to the corresponding PostgREST operator
        String postgrestOperator = "";
        switch (operator) {
          case '=':
            postgrestOperator = 'eq.';
            break;
          case '>':
            postgrestOperator = 'gt.';
            break;
          case '>=':
            postgrestOperator = 'gte.';
            break;
          case '<':
            postgrestOperator = 'lt.';
            break;
          case '<=':
            postgrestOperator = 'lte.';
            break;
          // TODO: TEST
          case 'LIKE':
            postgrestOperator = 'like';
            break;
          // TODO: TEST
          case 'IN':
            postgrestOperator = 'in';
            break;
        }

        return {
          'column': column,
          'operator': postgrestOperator,
          'value': value.replaceAll("'", ""),
        };
      }).toList();

      for (var arg in whereArgs) {
        filterCondition[arg['column']] = {
          "operator": arg['operator'],
          "value": arg['value']
        };
      }
    }

    // Create a DELETE request to the URL
    http.Response response = await http
        .delete(Uri.parse(url), body: jsonEncode(filterCondition), headers: {
      'Content-Type': 'application/json',
      'apikey': supabaseKey,
    });

    if (response.statusCode >= 400) {
      throw Exception(response.body);
    }

    final _ = json.decode(response.body);

    return QueryResults();
  }

  /// Executing a given [rawSql] string statement and returns the rows
  Future<QueryResults> sql(String rawSql) async {
    // Use the sqlparser library to parse the raw SQL string
    var parser = SqlEngine();
    var statement = parser.parse(rawSql).rootNode;
    QueryResults results;

    switch (statement.runtimeType) {
      case SelectStatement:
        print("SelectStatement");
        results = await _performSelect(statement as SelectStatement);
        break;
      case InsertStatement:
        print("InsertStatement");
        results = await _performInsert(statement as InsertStatement);
        break;
      // case UpdateStatement:
      //   print("UpdateStatement");
      //   // results = await _performInsert(statement as InsertStatement);
      //   break;
      case DeleteStatement:
        print("DeleteStatement");
        results = await _performDelete(statement as DeleteStatement);
        break;

      default:
        if (rawSql.toLowerCase().contains('select')) {
          results = await _sqlToDartOld(rawSql);
        } else {
          throw Exception("Unsupported SQL statement");
        }
    }
    return results;
  }

  /// Returns a stream that listen to changes when [eventType] occurred in [table]
  Stream<dynamic> on(String table, CrudEvent? eventType) {
    return _database.onTableChanged(table, event: eventType);
  }

  /// Returns a stream that listen to changes when 'INSERT' occurred in [table]
  Stream<dynamic> onInsert(String table) {
    return _database.onTableChanged(table, event: CrudEvent.insert);
  }

  /// Returns a stream that listen to changes when 'UPDATE' occurred in [table]
  Stream<dynamic> onUpdate(String table) {
    return _database.onTableChanged(table, event: CrudEvent.update);
  }

  /// Returns a stream that listen to changes when 'DELETE' occurred in [table]
  Stream<dynamic> onDelete(String table) {
    return _database.onTableChanged(table, event: CrudEvent.delete);
  }

  /// Closes all the open stream done with listening to table changes
  Future<void> closeAllStreams() => _database.closeAllStream();
}

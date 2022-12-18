import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sqlparser/sqlparser.dart';
import 'package:supabase/supabase.dart';
import 'list_ext.dart';

extension SupabaseExtensions on SupabaseClient{
  Future<List<Map<String, dynamic>>> _performSelect(SelectStatement statement) async {
    // Extract the table name, column names, and WHERE clause from the statement
    String tableName = statement.from?.first.toString().split(':')[1].trim() ?? "";
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
            postgrestOperator = 'like';
            break;

        }

        return {
          'column': column,
          'operator': postgrestOperator,
          'value': value,

         };
      });

      whereClause = whereArgs.map((arg) => '${arg['column']}=${arg['operator']}${arg['value']}').join('&');
    }
    var orderbyClauses = <String>[];
    if(statement.orderBy != null){
      var orderingTerms = statement.orderBy!.childNodes.map((e) => e as OrderingTerm);
      for(var term in orderingTerms){
        var field = "${term.expression}";
        var ordering = term.orderingMode != OrderingMode.descending ? 'asc' : 'desc';
        orderbyClauses.add("$field.$ordering");
      }
    }

    // Build the URL with query parameters
    String url = "$supabaseUrl/rest/v1/$tableName?";
    if (columnNames.isNotEmpty) {
      url += "select=${Uri.encodeQueryComponent(columnNames.join(","))}";
    }
    if (whereClause.isNotEmpty) {
      url += "&$whereClause";

    }
    if (statement.orderBy != null) {
      url += "&order=${orderbyClauses.join(',')}";
    }
    // if (statement.distinct) {
    //   url += "&distinct=true";
    // }
    if(statement.limit != null){
      url += "&limit=${(statement.limit! as Limit).count.toString().split('value ')[1]}";
    }

    // GET https://rbwvyxnhamichywqgjqb.supabase.co/rest/v1/courses?code=eq.90023 ??

    // print("GET $url");
    // Create a GET request to the URL
    http.Response response = await http.get(Uri.parse(url),
        headers: {
          'apikey': supabaseKey,
        });


    final data = json.decode(response.body);

    if (response.statusCode > 400){
      throw Exception("incorrect SQL statement");
    }
    List<Map<String, dynamic>> finalData = data.cast<Map<String,dynamic>>();

    // "Distinct" trick on the list:
    if(statement.distinct){
      return finalData.distinct();
    }
    return finalData;

  }

  Future<List<Map<String, dynamic>>> _sqlToDartOld(String sql) async {
    print("SQL = $sql");
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

    final apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJid3Z5eG5oYW1pY2h5d3FnanFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NTU1NzcwNDcsImV4cCI6MTk3MTE1MzA0N30.CRalEPItZFPIRyGNz2_pmbALRHK1KMNVzejUsW_GnZY';
    final endpoint = 'https://rbwvyxnhamichywqgjqb.supabase.co';

    final response = await http.get(Uri.parse(
        '$endpoint/rest/v1/$table?${whereArgs.map((
            arg) => '${arg['column']}=${arg['operator']}${arg['value']}').join(
            '&')}'
    ), headers: {
      'apikey': apiKey,
    });
    final data = json.decode(response.body);
    if (response.statusCode > 400){
      throw Exception("incorrect SQL statement");
    }
    List<Map<String, dynamic>> finalData = data.cast<Map<String,dynamic>>();
    return finalData;
  }

  Future<List<Map<String, dynamic>>> sql(String rawSql) async {
    // Use the sqlparser library to parse the raw SQL string
    var parser = SqlEngine();
    var statement = parser.parse(rawSql).rootNode;
    List<Map<String, dynamic>> results = [];

    switch(statement.runtimeType){
      case SelectStatement:
        print("SelectStatement");
        results = await _performSelect(statement as SelectStatement);
        break;
      case InsertStatement:
        print("InsertStatement");
        throw Exception("Insert Statement is Unsupported");
    // break;
      case UpdateStatement:
        print("UpdateStatement");
        throw Exception("Update Statement is Unsupported");
    // break;
      case DeleteStatement:
        print("DeleteStatement");
        throw Exception("Delete Statement is Unsupported");
    // break;

      default:
        if(rawSql.toLowerCase().contains('select')){
          results = await _sqlToDartOld(rawSql);
        }
        else {
          throw Exception("Unsupported SQL statement");
        }
    }
    return results;
  }
}
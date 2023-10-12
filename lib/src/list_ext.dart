import 'dart:convert';

/// Extension to handle better list result from SQL
extension ListExtension on List<Map<String, dynamic>> {
  /// Return list without duplicates, in a similar manner to DISTINCT in sql
  List<Map<String, dynamic>> distinct() {
    // Create a set to store the distinct objects
    var distinctObjects = <String>{};

    // Iterate through the list of objects
    for (var object in this) {
      // Convert the object to a string and add it to the set
      distinctObjects.add(json.encode(object));
    }

    // Convert the set back to a list of objects
    return distinctObjects
        .map((str) => json.decode(str) as Map<String, dynamic>)
        .toList();
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:shapefile/shapefile.dart' as shapefile;
import 'package:test/test.dart';

void main() {
  group("convert data in .dbf file", () {
    test("number-null-property", () async {
      expect(
          actualData("./test/shapefile/number-null-property.dbf"),
          emitsInOrder(
              expectedData("./test/shapefile/number-null-property.json")));
    });
    test("string-property", () async {
      expect(actualData("./test/shapefile/string-property.dbf"),
          emitsInOrder(expectedData("./test/shapefile/string-property.json")));
    });
    test("mixed-properties", () async {
      expect(actualData("./test/shapefile/mixed-properties.dbf"),
          emitsInOrder(expectedData("./test/shapefile/mixed-properties.json")));
    });
    test("date-property", () async {
      expect(actualData("./test/shapefile/date-property.dbf"),
          emitsInOrder(expectedData("./test/shapefile/date-property.json")));
    });
    test("utf8-property", () async {
      expect(actualData("./test/shapefile/utf8-property.dbf"),
          emitsInOrder(expectedData("./test/shapefile/utf8-property.json")));
    });
  });
}

Stream<Map<String, dynamic>> actualData(String path) =>
    fixActualData(shapefile.data(File(path).openRead()));

Iterable<Map> expectedData(String path) => fixExpectedData(
    (jsonDecode(File(path).readAsStringSync())["features"] as List)
        .map((f) => f["properties"]));

Stream<Map<String, dynamic>> fixActualData(Stream<Map<String, dynamic>> data) =>
    data.map((properties) {
      properties.removeWhere((_, value) => value == null);
      return properties;
    });

Iterable<Map> fixExpectedData(Iterable<Map> data) => data.map((properties) {
      String? d = properties["date"];
      if (d != null) properties["date"] = DateTime.parse(d);
      return properties;
    });

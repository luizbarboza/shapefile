import 'dart:convert';
import 'dart:io';

import 'package:shapefile/shapefile.dart' as shapefile;
import 'package:test/test.dart';

void main() {
  group("convert features in .shp file", () {
    test("empty", () async {
      expect(actualFeatures("./test/shapefile/empty"),
          emitsInOrder(expectedFeatures("./test/shapefile/empty.json")));
    });
    test("boolean-property", () async {
      expect(
          actualFeatures("./test/shapefile/boolean-property"),
          emitsInOrder(
              expectedFeatures("./test/shapefile/boolean-property.json")));
    });
    test("number-property", () async {
      expect(
          actualFeatures("./test/shapefile/number-property"),
          emitsInOrder(
              expectedFeatures("./test/shapefile/number-property.json")));
    });
    test("number-null-property", () async {
      expect(
          actualFeatures("./test/shapefile/number-null-property"),
          emitsInOrder(
              expectedFeatures("./test/shapefile/number-null-property.json")));
    });
    test("string-property", () async {
      expect(
          actualFeatures("./test/shapefile/string-property"),
          emitsInOrder(
              expectedFeatures("./test/shapefile/string-property.json")));
    });
    test("mixed-properties", () async {
      expect(
          actualFeatures("./test/shapefile/mixed-properties"),
          emitsInOrder(
              expectedFeatures("./test/shapefile/mixed-properties.json")));
    });
    test("date-property", () async {
      expect(
          actualFeatures("./test/shapefile/date-property"),
          emitsInOrder(
              expectedFeatures("./test/shapefile/date-property.json")));
    });
    test("utf8-property", () async {
      expect(
          actualFeatures("./test/shapefile/utf8-property"),
          emitsInOrder(
              expectedFeatures("./test/shapefile/utf8-property.json")));
    });
    test("latin1-property", () async {
      expect(
          actualFeatures("./test/shapefile/latin1-property", encoding: latin1),
          emitsInOrder(
              expectedFeatures("./test/shapefile/latin1-property.json")));
    });
    test("points", () async {
      expect(actualFeatures("./test/shapefile/points"),
          emitsInOrder(expectedFeatures("./test/shapefile/points.json")));
    });
    test("multipoints", () async {
      expect(actualFeatures("./test/shapefile/multipoints"),
          emitsInOrder(expectedFeatures("./test/shapefile/multipoints.json")));
    });
    test("polylines", () async {
      expect(actualFeatures("./test/shapefile/polylines"),
          emitsInOrder(expectedFeatures("./test/shapefile/polylines.json")));
    });
    test("polygons", () async {
      expect(actualFeatures("./test/shapefile/polygons"),
          emitsInOrder(expectedFeatures("./test/shapefile/polygons.json")));
    });
    test("null", () async {
      expect(actualFeatures("./test/shapefile/null"),
          emitsInOrder(expectedFeatures("./test/shapefile/null.json")));
    });
    test("ignore-properties", () async {
      expect(
          actualFeatures("./test/shapefile/ignore-properties",
              ignoreProperties: true),
          emitsInOrder(
              expectedFeatures("./test/shapefile/ignore-properties.json")));
    });
  });
}

Stream<Map<String, dynamic>?> actualFeatures(String path,
        {Encoding encoding = utf8, bool ignoreProperties = false}) =>
    fixActualFeatures(shapefile.features(File("$path.shp").openRead(),
        dbf: ignoreProperties ? null : File("$path.dbf").openRead(),
        encoding: encoding));

Iterable expectedFeatures(String path) =>
    fixExpectedFeatures(jsonDecode(File(path).readAsStringSync())["features"]);

Stream<Map<String, dynamic>> fixActualFeatures(
        Stream<Map<String, dynamic>> features) =>
    features.map((feature) {
      (feature["properties"] as Map)
        ..removeWhere((_, value) => value == null)
        ..remove("FID");
      return feature;
    });

Iterable fixExpectedFeatures(Iterable features) => features.map((feature) {
      Map properties = feature["properties"];
      String? d = properties["date"];
      if (d != null) properties["date"] = DateTime.parse(d);
      return feature;
    });

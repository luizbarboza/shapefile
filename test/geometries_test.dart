import 'dart:convert';
import 'dart:io';

import 'package:shapefile/shapefile.dart' as shapefile;
import 'package:test/test.dart';

void main() {
  group("convert geometries in .shp file", () {
    test("ignore-properties", () async {
      expect(
          actualGeometries("./test/shapefile/ignore-properties.shp"),
          emitsInOrder(
              expectedGeometries("./test/shapefile/ignore-properties.json")));
    });
    test("multipointm", () async {
      expect(
          actualGeometries("./test/shapefile/multipointm.shp"),
          emitsInOrder(
              expectedGeometries("./test/shapefile/multipointm.json")));
    });
    test("pointm", () async {
      expect(actualGeometries("./test/shapefile/pointm.shp"),
          emitsInOrder(expectedGeometries("./test/shapefile/pointm.json")));
    });
    test("polygonm", () async {
      expect(actualGeometries("./test/shapefile/polygonm.shp"),
          emitsInOrder(expectedGeometries("./test/shapefile/polygonm.json")));
    });
    test("polylinem", () async {
      expect(actualGeometries("./test/shapefile/polylinem.shp"),
          emitsInOrder(expectedGeometries("./test/shapefile/polylinem.json")));
    });
    test("ne_10m_time_zones", () async {
      expect(
          actualGeometries("./test/shapefile/ne_10m_time_zones.shp"),
          emitsInOrder(
              expectedGeometries("./test/shapefile/ne_10m_time_zones.json")));
    });
    test("ne_10m_railroads", () async {
      expect(
          actualGeometries("./test/shapefile/ne_10m_railroads.shp"),
          emitsInOrder(
              expectedGeometries("./test/shapefile/ne_10m_railroads.json")));
    }, timeout: const Timeout(Duration(seconds: 180)));
  });
}

Stream<Map<String, dynamic>?> actualGeometries(String path) =>
    shapefile.geometries(File(path).openRead());

Iterable<Map> expectedGeometries(String path) =>
    (jsonDecode(File(path).readAsStringSync())["features"] as List)
        .map((f) => f["geometry"]);

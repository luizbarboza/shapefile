import 'dart:convert';

import 'package:async/async.dart';

import '../data/index.dart';
import '../geometries/index.dart';

/// Returns a GeoJSON Feature stream.
///
/// Both [shp] and [dbf] must be a chunked byte-stream.
///
/// The follwing option are supported: `encoding` - the dBASE character
/// encoding; defaults to “UTF-8”
Stream<Map<String, dynamic>> features(
  Stream<List<int>> shp, {
  Stream<List<int>>? dbf,
  Encoding encoding = utf8,
  void Function(List<double>)? forBbox,
}) {
  final streams = [geometries(shp, forBbox: forBbox)];
  if (dbf != null) streams.add(data(dbf, encoding: encoding));
  return StreamZip(streams).map((results) => {
        "type": "Feature",
        "properties": results.length > 1 ? results[1] : {},
        "geometry": results[0]
      });
}

/// Returns a future that yields a
/// [GeoJSON feature collection](http://geojson.org/geojson-spec.html#feature-collection-objects)
/// for specified shapefile [shp] and dBASE table file [dbf].
///
/// The meaning of the arguments is the same as [features]. This is a
/// convenience API for reading an entire shapefile in one go; use this method
/// if you don’t mind putting the whole shapefile in memory. The yielded
/// *collection* has a bbox property representing the bounding box of all
/// records in this shapefile. The bounding box is specified as \[*xmin*,
/// *ymin*, *xmax*, *ymax*\], where *x* and *y* represent longitude and latitude
/// in spherical coordinates.
///
/// The
/// [coordinate reference system](http://geojson.org/geojson-spec.html#coordinate-reference-system-objects)
/// of the feature collection is not specified. This library does not support
/// parsing coordinate reference system specifications (.prj); see
/// [Proj4js](https://github.com/proj4js/proj4js) for parsing
/// [well-known text (WKT)](https://en.wikipedia.org/wiki/Well-known_text#Coordinate_reference_system)
/// specifications.
Future<Map<String, dynamic>> featureCollection(
  Stream<List<int>> shp, {
  Stream<List<int>>? dbf,
  Encoding encoding = utf8,
}) async {
  final collection = <String, dynamic>{
    "type": "FeatureCollection",
  };
  collection["features"] = await features(
    shp,
    dbf: dbf,
    forBbox: (bbox) => collection["bbox"] = bbox,
  ).toList();
  return collection;
}

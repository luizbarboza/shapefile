import 'dart:typed_data';

import 'package:async/async.dart';

import '../features/index.dart';
import 'list_extensions.dart';
import 'multipoint.dart';
import 'null.dart';
import 'point.dart';
import 'polygon.dart';
import 'polyline.dart';

Map<int, Map<String, dynamic>? Function(ByteData)> _parsers = {
  0: parseNull,
  1: parsePoint,
  3: parsePolyLine,
  5: parsePolygon,
  8: parseMultiPoint,
  11: parsePoint, // PointZ
  13: parsePolyLine, // PolyLineZ
  15: parsePolygon, // PolygonZ
  18: parseMultiPoint, // MultiPointZ
  21: parsePoint, // PointM
  23: parsePolyLine, // PolyLineM
  25: parsePolygon, // PolygonM
  28: parseMultiPoint // MultiPointM
};

/// Returns a GeoJSON geometry stream.
///
/// Unlike [features], this only reads the shapefile, and never the associated
/// dBASE file.
///
/// The [source] must be a chunked byte-stream.
Stream<Map<String, dynamic>?> geometries(Stream<List<int>> source,
    {void Function(List<double>)? forBbox}) async* {
  var r = ChunkedStreamReader(source),
      header = ByteData.sublistView(await r.readBytes(100)),
      type = header.getInt32(32, Endian.little),
      index = 1,
      parse = _parsers[type]!;
  if (forBbox != null) {
    forBbox([
      header.getFloat64(36, Endian.little),
      header.getFloat64(44, Endian.little),
      header.getFloat64(52, Endian.little),
      header.getFloat64(60, Endian.little)
    ]);
  }

  Uint8List list;
  while ((list = await r.readBytes(12)).isNotEmpty) {
    var header = ByteData.sublistView(list);

    Stream<Map<String, dynamic>?> read() async* {
      Stream<Map<String, dynamic>?> skip() async* {
        var chunk = await r.readBytes(4);
        if (chunk.isNotEmpty) {
          header = ByteData.sublistView(list = list.sublist(4).concat(chunk));
          if (header.getInt32(0) != index) {
            yield* skip();
          } else {
            yield* read();
          }
        }
      }

      var length = header.getInt32(4) * 2 - 4,
          rtype = header.getInt32(8, Endian.little);
      if (length < 0 || (rtype != 0 && rtype != type)) {
        yield* skip();
      } else {
        yield rtype != 0
            ? parse(ByteData.sublistView(
                list.sublist(8).concat(await r.readBytes(length))))
            : null;
      }
    }

    yield* read();
    index++;
  }
  r.cancel();
}

/// Returns a future that yields a
/// [GeoJSON geometry collection](http://geojson.org/geojson-spec.html#geometry-collection)
/// for specified shapefile [source].
///
/// Unlike [featureCollection], this only reads the shapefile, and never the
/// associated dBASE file.
///
/// The meaning of the arguments is the same as [geometries]. This is a
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
Future<Map<String, dynamic>> geometryCollection(
    Stream<List<int>> source) async {
  var collection = <String, dynamic>{
    "type": "GeometryCollection",
  };
  collection["geometries"] =
      await geometries(source, forBbox: (bbox) => collection["bbox"] = bbox)
          .toList();
  return collection;
}

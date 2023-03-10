import 'dart:typed_data';

import 'list_extensions.dart';

Map<String, dynamic> parsePolygon(ByteData record) {
  var i = 44,
      n = record.getInt32(36, Endian.little),
      m = record.getInt32(40, Endian.little),
      parts = List.generate(n, (j) {
        var part = record.getInt32(i, Endian.little);
        i += 4;
        return part;
      }),
      points = List.generate(m, (j) {
        var point = [
          record.getFloat64(i, Endian.little),
          record.getFloat64(i + 8, Endian.little)
        ];
        i += 16;
        return point;
      }),
      polygons = <List<List<List<double>>>>[],
      holes = <List<List<double>>>[];

  var last = parts.length - 1;
  parts.forEachIndexed((i, j) {
    var ring = points.sublist(i, j == last ? null : parts[j + 1]);
    if (ringClockwise(ring)) {
      polygons.add([ring]);
    } else {
      holes.add(ring);
    }
  });

  for (final hole in holes) {
    if (!polygons.any((polygon) {
      if (ringContainsSome(polygon[0], hole)) {
        polygon.add(hole);
        return true;
      }
      return false;
    })) polygons.add([hole]);
  }

  return polygons.length == 1
      ? {"type": "Polygon", "coordinates": polygons[0]}
      : {"type": "MultiPolygon", "coordinates": polygons};
}

bool ringClockwise(List<List<double>> ring) {
  int n;
  if ((n = ring.length) < 4) return false;
  var i = 0, area = ring[n - 1][1] * ring[0][0] - ring[n - 1][0] * ring[0][1];
  while (++i < n) {
    area += ring[i - 1][1] * ring[i][0] - ring[i - 1][0] * ring[i][1];
  }
  return area >= 0;
}

bool ringContainsSome(List<List<double>> ring, List<List<double>> hole) {
  int i = -1, n = hole.length, c;
  while (++i < n) {
    if ((c = ringContains(ring, hole[i])) != 0) {
      return c > 0;
    }
  }
  return false;
}

int ringContains(List<List<double>> ring, List<double> point) {
  var x = point[0], y = point[1], contains = -1;
  for (var i = 0, n = ring.length, j = n - 1; i < n; j = i++) {
    var pi = ring[i],
        xi = pi[0],
        yi = pi[1],
        pj = ring[j],
        xj = pj[0],
        yj = pj[1];
    if (segmentContains(pi, pj, point)) {
      return 0;
    }
    if (((yi > y) != (yj > y)) &&
        ((x < (xj - xi) * (y - yi) / (yj - yi) + xi))) {
      contains = -contains;
    }
  }
  return contains;
}

bool segmentContains(List<double> p0, List<double> p1, List<double> p2) {
  var x20 = p2[0] - p0[0], y20 = p2[1] - p0[1];
  if (x20 == 0 && y20 == 0) return true;
  var x10 = p1[0] - p0[0], y10 = p1[1] - p0[1];
  if (x10 == 0 && y10 == 0) return false;
  var t = (x20 * x10 + y20 * y10) / (x10 * x10 + y10 * y10);
  return !(t < 0 || t > 1) &&
      ((t == 0 || t == 1) || (t * x10 == x20 && t * y10 == y20));
}

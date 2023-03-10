import 'dart:typed_data';

import 'list_extensions.dart';

Map<String, dynamic> parsePolyLine(ByteData record) {
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
      last = parts.length - 1;
  return n == 1
      ? {"type": "LineString", "coordinates": points}
      : {
          "type": "MultiLineString",
          "coordinates": parts.mapIndexed(
              (i, j) => points.sublist(i, j == last ? null : parts[j + 1]))
        };
}

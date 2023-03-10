import 'dart:typed_data';

Map<String, dynamic> parseMultiPoint(ByteData record) {
  var i = 24,
      n = record.getInt32(36, Endian.little),
      coordinates = List.generate(n, (j) {
        i += 16;
        return [
          record.getFloat64(i, Endian.little),
          record.getFloat64(i + 8, Endian.little)
        ];
      });
  return {"type": "MultiPoint", "coordinates": coordinates};
}

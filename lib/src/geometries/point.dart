import 'dart:typed_data';

Map<String, dynamic> parsePoint(ByteData record) => {
      "type": "Point",
      "coordinates": [
        record.getFloat64(4, Endian.little),
        record.getFloat64(12, Endian.little)
      ]
    };

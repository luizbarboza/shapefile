import 'dart:convert';
import 'dart:typed_data';

import 'package:async/async.dart';

import '../features/index.dart';
import 'boolean.dart';
import 'date.dart';
import 'number.dart';
import 'string.dart';

Map<String, Function> _types = {
  "B": readNumber,
  "C": readString,
  "D": readDate,
  "F": readNumber,
  "L": readBoolean,
  "M": readNumber,
  "N": readNumber
};

/// Returns a GeoJSON properties object stream.
///
/// Unlike [features], this only reads the dBASE file, and never the associated
/// shapefile.
///
/// The [source] must be a chunked byte-stream.
Stream<Map<String, dynamic>> data(Stream<List<int>> source,
    {Encoding encoding = utf8}) async* {
  var r = ChunkedStreamReader(source),
      head = ByteData.sublistView(await r.readBytes(32)),
      body = ByteData.sublistView(
          await r.readBytes(head.getUint16(8, Endian.little) - 32)),
      recordLength = head.getUint16(10, Endian.little),
      fields = <Map<String, dynamic>>[];

  for (var n = 0; body.getUint8(n) != 0x0d; n += 32) {
    int j;
    for (j = 0; j < 11; ++j) {
      if (body.getUint8(n + j) == 0) break;
    }
    fields.add({
      "name": encoding
          .decode(Uint8List.view(body.buffer, body.offsetInBytes + n, j)),
      "type": String.fromCharCode(body.getUint8(n + 11)),
      "length": body.getUint8(n + 16)
    });
  }

  Uint8List value;
  while ((value = await r.readBytes(recordLength)).isNotEmpty &&
      value[0] != 0x1a) {
    var i = 1;
    yield fields.fold({}, (p, f) {
      p[f["name"]] = _types[f["type"]]!(
          encoding.decode(value.sublist(i, i += (f["length"] as int))));
      return p;
    });
  }
}

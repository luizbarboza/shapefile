final reFalse = RegExp(r'^[nf]$', caseSensitive: false);
final reTrue = RegExp(r'^[yt]$', caseSensitive: false);

bool? readBoolean(String value) => value.contains(reFalse)
    ? false
    : value.contains(reTrue)
        ? true
        : null;

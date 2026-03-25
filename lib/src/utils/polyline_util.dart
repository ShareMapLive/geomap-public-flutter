import 'package:latlong2/latlong.dart';

/// Utility class for polyline encoding/decoding
class PolylineUtil {
  /// Decode a polyline string to a list of LatLng points
  static List<LatLng> decode(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng p = LatLng(lat / 1E5, lng / 1E5);
      poly.add(p);
    }

    return poly;
  }

  /// Encode a list of LatLng points to a polyline string
  static String encode(List<LatLng> points) {
    StringBuffer encoded = StringBuffer();
    int lastLat = 0, lastLng = 0;

    for (LatLng point in points) {
      int lat = (point.latitude * 1E5).round();
      int lng = (point.longitude * 1E5).round();

      int dLat = lat - lastLat;
      int dLng = lng - lastLng;

      encoded.write(_encodeSignedNumber(dLat));
      encoded.write(_encodeSignedNumber(dLng));

      lastLat = lat;
      lastLng = lng;
    }

    return encoded.toString();
  }

  /// Helper method to encode a signed number
  static String _encodeSignedNumber(int num) {
    int sgnNum = num << 1;
    if (num < 0) {
      sgnNum = ~sgnNum;
    }
    return _encodeNumber(sgnNum);
  }

  /// Helper method to encode a number
  static String _encodeNumber(int num) {
    StringBuffer encoded = StringBuffer();
    while (num >= 0x20) {
      encoded.write(String.fromCharCode((0x20 | (num & 0x1f)) + 63));
      num >>= 5;
    }
    encoded.write(String.fromCharCode(num + 63));
    return encoded.toString();
  }
}

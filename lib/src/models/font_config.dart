import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuration for custom fonts used in the geomap widget
class FontConfig {
  /// Font family for mobile platform
  final String mobileFontFamily;

  /// Font family for web platform
  final String webFontFamily;

  /// Font size for titles
  final double titleFontSize;

  /// Font size for subtitles
  final double subtitleFontSize;

  /// Font size for body text
  final double bodyFontSize;

  /// Font weight for bold text
  final FontWeight boldFontWeight;

  /// Font weight for regular text
  final FontWeight regularFontWeight;

  const FontConfig({
    this.mobileFontFamily = 'RobotoRegular',
    this.webFontFamily = 'PoppinsRegular',
    this.titleFontSize = 18.0,
    this.subtitleFontSize = 16.0,
    this.bodyFontSize = 14.0,
    this.boldFontWeight = FontWeight.bold,
    this.regularFontWeight = FontWeight.normal,
  });

  /// Get the appropriate font family based on the platform
  String get fontFamily => kIsWeb ? webFontFamily : mobileFontFamily;

  /// Create a TextStyle for titles
  TextStyle titleStyle(
      {Color? color, FontWeight? fontWeight, double? fontSize}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize ?? titleFontSize,
      fontWeight: fontWeight ?? boldFontWeight,
      color: color,
    );
  }

  /// Create a TextStyle for subtitles
  TextStyle subtitleStyle(
      {Color? color, FontWeight? fontWeight, double? fontSize}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize ?? subtitleFontSize,
      fontWeight: fontWeight ?? regularFontWeight,
      color: color,
    );
  }

  /// Create a TextStyle for body text
  TextStyle bodyStyle(
      {Color? color, FontWeight? fontWeight, double? fontSize}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize ?? bodyFontSize,
      fontWeight: fontWeight ?? regularFontWeight,
      color: color,
    );
  }
}

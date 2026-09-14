import 'dart:math' as math;

import 'package:flutter/material.dart';

class NaturalBreaksColorScale {
  static const List<Color> _defaultPalette = [
    Color(0xFFD32F2F),
    Color(0xFFF57C00),
    Color(0xFFFDD835),
    Color(0xFF32CD32),
    Color(0xFF66D9A8),
  ];

  final List<double> _breaks;
  final List<Color> _colors;

  NaturalBreaksColorScale._(this._breaks, this._colors);

  factory NaturalBreaksColorScale.fromValues(
    List<double> values, {
    int classCount = 5,
    List<Color>? palette,
  }) {
    final finiteValues = values.where((value) => value.isFinite).toList()
      ..sort();

    if (finiteValues.isEmpty) {
      return NaturalBreaksColorScale._(
        const [],
        (palette ?? _defaultPalette).take(classCount).toList(),
      );
    }

    final effectiveClassCount = math.max(
      1,
      math.min(classCount, finiteValues.length),
    );
    final effectiveColors = (palette ?? _defaultPalette)
        .take(effectiveClassCount)
        .toList(growable: false);

    final breaks = _calculateJenksBreaks(finiteValues, effectiveClassCount);
    return NaturalBreaksColorScale._(breaks, effectiveColors);
  }

  Color colorFor(double? value, {Color fallback = Colors.grey}) {
    if (value == null || value.isNaN || value.isInfinite) {
      return fallback;
    }

    if (_breaks.isEmpty || _colors.isEmpty) {
      return fallback;
    }

    for (var index = 1; index < _breaks.length; index++) {
      if (value <= _breaks[index]) {
        return _colors[math.min(index - 1, _colors.length - 1)];
      }
    }

    return _colors.last;
  }

  List<double> get breaks => List.unmodifiable(_breaks);

  static List<double> _calculateJenksBreaks(
    List<double> data,
    int classCount,
  ) {
    final sorted = [...data]..sort();
    final numberOfValues = sorted.length;

    if (numberOfValues == 1 || classCount == 1) {
      return [sorted.first, sorted.last];
    }

    if (sorted.first == sorted.last) {
      return List<double>.filled(classCount + 1, sorted.first);
    }

    final lowerClassLimits = List.generate(
      numberOfValues + 1,
      (_) => List<int>.filled(classCount + 1, 0),
    );
    final varianceCombinations = List.generate(
      numberOfValues + 1,
      (_) => List<double>.filled(classCount + 1, double.infinity),
    );

    for (var i = 1; i <= classCount; i++) {
      lowerClassLimits[1][i] = 1;
      varianceCombinations[1][i] = 0.0;
      for (var j = 2; j <= numberOfValues; j++) {
        varianceCombinations[j][i] = double.infinity;
      }
    }

    for (var l = 2; l <= numberOfValues; l++) {
      var sum = 0.0;
      var sumSquares = 0.0;
      var weight = 0;

      for (var m = 1; m <= l; m++) {
        final lowerClassLimit = l - m + 1;
        final value = sorted[lowerClassLimit - 1];

        weight++;
        sum += value;
        sumSquares += value * value;

        final variance = sumSquares - (sum * sum / weight);
        final index = lowerClassLimit - 1;

        if (index == 0) {
          lowerClassLimits[l][1] = 1;
          varianceCombinations[l][1] = variance;
        } else {
          for (var j = 2; j <= classCount; j++) {
            final test = variance + varianceCombinations[index][j - 1];
            if (varianceCombinations[l][j] >= test) {
              lowerClassLimits[l][j] = lowerClassLimit;
              varianceCombinations[l][j] = test;
            }
          }
        }
      }

      lowerClassLimits[l][1] = 1;
      varianceCombinations[l][1] = sumSquares - (sum * sum / weight);
    }

    final breaks = List<double>.filled(classCount + 1, sorted.last);
    breaks[0] = sorted.first;
    breaks[classCount] = sorted.last;

    var k = numberOfValues;
    for (var count = classCount; count >= 2; count--) {
      final lowerClassLimit = lowerClassLimits[k][count];
      breaks[count - 1] = sorted[lowerClassLimit - 1];
      k = lowerClassLimit - 1;
    }

    return breaks;
  }
}
import '../models/fuzzy_number.dart';

class FuzzyCalculator {
  static Map<String, double> calcularPorNotas(
    List<int> notas,
    List<double> pesos,
  ) {
    if (notas.length != pesos.length) {
      throw ArgumentError('Notas e pesos devem ter o mesmo comprimento');
    }

    if (notas.isEmpty) {
      return _resultadoVazio();
    }

    double somaA = 0.0;
    double somaB = 0.0;
    double somaC = 0.0;
    double somaD = 0.0;
    double somaPesos = 0.0;

    for (int i = 0; i < notas.length; i++) {
      final fuzzy = FuzzyNumber(nota: notas[i]).calcular();
      final peso = pesos[i];

      somaD += fuzzy['d']! * peso;
      somaA += fuzzy['a']! * peso;
      somaB += fuzzy['b']! * peso;
      somaC += fuzzy['c']! * peso;
      somaPesos += peso;
    }

    if (somaPesos == 0.0) {
      return _resultadoVazio();
    }

    final d = somaD / somaPesos;
    final a = somaA / somaPesos;
    final b = somaB / somaPesos;
    final c = somaC / somaPesos;

    final centroide = (d + a + b + c) / 4.0;
    final base = c - d;
    final resultado = centroide < 0.1
        ? centroide
        : (centroide - 0.1) / 0.8;

    return {
      'd': d,
      'a': a,
      'b': b,
      'c': c,
      'centroide': centroide,
      'base': base,
      'resultado': resultado,
    };
  }

  static Map<String, double> _resultadoVazio() => {
        'd': 0.0,
        'a': 0.0,
        'b': 0.0,
        'c': 0.0,
        'centroide': 0.0,
        'base': 0.0,
        'resultado': 0.0,
      };
}

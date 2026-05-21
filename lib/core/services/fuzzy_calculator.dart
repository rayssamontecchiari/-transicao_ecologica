import '../models/fuzzy_number.dart';

class FuzzyCalculator {
  static Map<String, double> calcularPorNotas(
    List<int> notas,
    List<double> pesos,
  ) {
    if (notas.length != pesos.length) {
      throw ArgumentError(
        'Notas e pesos devem ter o mesmo comprimento',
      );
    }

    double somaA = 0;
    double somaB = 0;
    double somaC = 0;
    double somaD = 0;

    double somaPesos = 0;

    for (int i = 0; i < notas.length; i++) {
      final fuzzy = FuzzyNumber(
        nota: notas[i],
      );

      final res = fuzzy.calcular();

      // PESO aplicado SOMENTE aqui
      somaA += res['a']! * pesos[i];
      somaB += res['b']! * pesos[i];
      somaC += res['c']! * pesos[i];
      somaD += res['d']! * pesos[i];

      somaPesos += pesos[i];
    }

    final a = somaA / somaPesos;
    final b = somaB / somaPesos;
    final c = somaC / somaPesos;
    final d = somaD / somaPesos;

    final centroide = (a + b + c + d) / 4.0;

    final base = c - d;

    final resultado = centroide < 0.1 ? centroide : (centroide - 0.1) / 0.8;

    return {
      'a': a,
      'b': b,
      'c': c,
      'd': d,
      'centroide': centroide,
      'base': base,
      'resultado': resultado,
    };
  }
}

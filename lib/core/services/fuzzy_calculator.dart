import '../models/fuzzy_number.dart';

class FuzzyCalculator {
  /// Calcula resultado final baseado em notas e pesos
  static Map<String, double> calcularPorNotas(
    List<int> notas,
    List<double> pesos,
  ) {
    if (notas.length != pesos.length) {
      throw ArgumentError('Notas e pesos devem ter o mesmo comprimento');
    }

    double somaA = 0, somaB = 0, somaC = 0, somaD = 0;
    double totalPeso = 0;

    for (int i = 0; i < notas.length; i++) {
      final fuzzy = FuzzyNumber(
        nota: notas[i],
        peso: pesos[i],
      );

      final res = fuzzy.calcular();

      somaA += res['a']! * pesos[i];
      somaB += res['b']! * pesos[i];
      somaC += res['c']! * pesos[i];
      somaD += res['d']! * pesos[i];

      totalPeso += pesos[i];
    }

    final a = somaA / totalPeso;
    final b = somaB / totalPeso;
    final c = somaC / totalPeso;
    final d = somaD / totalPeso;

    final centroide = (a + b + c + d) / 4;
    final base = c - d;

    double resultado;
    if (centroide < 0.1) {
      resultado = centroide;
    } else {
      resultado = (centroide - 0.1) / 0.8;
    }

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

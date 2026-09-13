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

    if (notas.isEmpty) {
      return {
        'a': 0.0,
        'b': 0.0,
        'c': 0.0,
        'd': 0.0,
        'centroide': 0.0,
        'base': 0.0,
        'resultado': 0.0,
      };
    }

    double somaA = 0.0;
    double somaB = 0.0;
    double somaC = 0.0;
    double somaD = 0.0;
    double somaPesos = 0.0;

    for (int i = 0; i < notas.length; i++) {
      final fuzzy = FuzzyNumber(
        nota: notas[i],
      );

      final res = fuzzy.calcular();

      somaA += res['a']! * pesos[i];
      somaB += res['b']! * pesos[i];
      somaC += res['c']! * pesos[i];
      somaD += res['d']! * pesos[i];
      somaPesos += pesos[i];
    }

    if (somaPesos == 0.0) {
      return {
        'a': 0.0,
        'b': 0.0,
        'c': 0.0,
        'd': 0.0,
        'centroide': 0.0,
        'base': 0.0,
        'resultado': 0.0,
      };
    }

    final a = somaA / somaPesos;
    final b = somaB / somaPesos;
    final c = somaC / somaPesos;
    final d = somaD / somaPesos;

    // Defuzzificacao conforme planilha: media simples dos 4 componentes finais.
    final centroide = (a + b + c + d) / 4.0;

    final base = c - d;

    // Normalizacao da planilha: acima de 0.1, reescala no intervalo [0.1, 0.9].
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

import '../models/fuzzy_number.dart';

/// Calcula resultados usando lógica fuzzy para as avaliações
class FuzzyCalculator {
  /// Mapeia notas (0-5) para triângulos fuzzy (d, a, b, c)
  /// Segue a tabela de mapeamento da avaliação
  static final Map<int, List<double>> notaParaTriangulo = {
    0: [0.0, 0.0, 0.0, 0.0],
    1: [0.0, 0.0, 0.1, 0.3],
    2: [0.1, 0.3, 0.3, 0.5],
    3: [0.3, 0.5, 0.5, 0.7],
    4: [0.5, 0.7, 0.7, 0.9],
    5: [0.7, 0.9, 1.0, 1.0],
  };

  /// Obter número fuzzy para uma nota com seu peso
  static FuzzyNumber fuzzyParaNota(int nota, double peso) {
    final valores = notaParaTriangulo[nota] ?? [0.0, 0.0, 0.0, 0.0];
    return FuzzyNumber(
      d: valores[0],
      a: valores[1],
      b: valores[2],
      c: valores[3],
      weight: peso,
    );
  }

  /// Calcula o resultado final para um conjunto de atributos fuzzy
  /// Retorna um mapa com centróide, base e valor normalizado
  static Map<String, double> calcularResultadoFinal(
    List<FuzzyNumber> atributos,
  ) {
    double sumD = 0;
    double sumA = 0;
    double sumB = 0;
    double sumC = 0;

    for (var atributo in atributos) {
      final weighted = atributo.applyWeight();

      sumD += weighted.d;
      sumA += weighted.a;
      sumB += weighted.b;
      sumC += weighted.c;
    }

    // Centróide é a média de todos os valores: (d + a + b + c) / 4
    final centroid = (sumD + sumA + sumB + sumC) / 4;

    // Base é a amplitude: c - d
    final base = sumC - sumD;

    // Normalizando conforme fórmula do sheet:
    // Se centroid < 0.1, resultado = centroid
    // Senão, resultado = (centroid - 0.1) / (0.9 - 0.1)
    double resultado;
    if (centroid < 0.1) {
      resultado = centroid;
    } else {
      resultado = (centroid - 0.1) / 0.8;
    }

    return {
      'centroid': centroid,
      'base': base,
      'resultado': resultado,
      'sumD': sumD,
      'sumA': sumA,
      'sumB': sumB,
      'sumC': sumC,
    };
  }

  /// Calcula resultado final baseado em notas Likert (1-5)
  /// com pesos dos indicadores
  static Map<String, double> calcularPorNotas(
    List<int> notas,
    List<double> pesos,
  ) {
    if (notas.length != pesos.length) {
      throw ArgumentError('Notas e pesos devem ter o mesmo comprimento');
    }

    final fuzzyNumbers = <FuzzyNumber>[];
    for (int i = 0; i < notas.length; i++) {
      fuzzyNumbers.add(fuzzyParaNota(notas[i], pesos[i]));
    }

    return calcularResultadoFinal(fuzzyNumbers);
  }

  /// Converte resultado fuzzy para faixa de desempenho
  static String interpretarResultado(double valor) {
    if (valor >= 8.0) return 'Muito Bom';
    if (valor >= 6.0) return 'Bom';
    if (valor >= 4.0) return 'Regular';
    if (valor >= 2.0) return 'Ruim';
    return 'Muito Ruim';
  }
}

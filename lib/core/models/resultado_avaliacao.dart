/// Resultado da avaliação de uma categoria específica
class ResultadoAvaliacao {
  final int avaliacaoId;
  final int categoriaId;
  final double valorFuzzyFinal;

  // Detalhes do cálculo fuzzy
  final double sumD;
  final double sumA;
  final double sumB;
  final double sumC;
  final double centroid;
  final double base;

  ResultadoAvaliacao({
    required this.avaliacaoId,
    required this.categoriaId,
    required this.valorFuzzyFinal,
    required this.sumD,
    required this.sumA,
    required this.sumB,
    required this.sumC,
    required this.centroid,
    required this.base,
  });

  /// Cria um resultado a partir de um mapa de cálculo fuzzy
  factory ResultadoAvaliacao.fromCalculation(
      {required int avaliacaoId,
      required int categoriaId,
      required Map<String, double> fuzzyResult}) {
    return ResultadoAvaliacao(
      avaliacaoId: avaliacaoId,
      categoriaId: categoriaId,
      valorFuzzyFinal: fuzzyResult['resultado'] ?? 0.0,
      sumD: fuzzyResult['d'] ?? 0.0,
      sumA: fuzzyResult['a'] ?? 0.0,
      sumB: fuzzyResult['b'] ?? 0.0,
      sumC: fuzzyResult['c'] ?? 0.0,
      centroid: fuzzyResult['centroide'] ?? 0.0,
      base: fuzzyResult['base'] ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'ResultadoAvaliacao(categoriaId: $categoriaId, valor: ${valorFuzzyFinal.toStringAsFixed(2)})';
  }
}

/// Resultado da avaliação de uma categoria específica
class ResultadoAvaliacao {
  final int avaliacaoId;
  final int categoriaId;
  final double valorFuzzyFinal;
  final String interpretacao;

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
    required this.interpretacao,
    required this.sumD,
    required this.sumA,
    required this.sumB,
    required this.sumC,
    required this.centroid,
    required this.base,
  });

  /// Cria um resultado a partir de um mapa de cálculo fuzzy
  factory ResultadoAvaliacao.fromCalculation({
    required int avaliacaoId,
    required int categoriaId,
    required Map<String, double> fuzzyResult,
    required String interpretacao,
  }) {
    return ResultadoAvaliacao(
      avaliacaoId: avaliacaoId,
      categoriaId: categoriaId,
      valorFuzzyFinal: fuzzyResult['resultado'] ?? 0.0,
      interpretacao: interpretacao,
      sumD: fuzzyResult['sumD'] ?? 0.0,
      sumA: fuzzyResult['sumA'] ?? 0.0,
      sumB: fuzzyResult['sumB'] ?? 0.0,
      sumC: fuzzyResult['sumC'] ?? 0.0,
      centroid: fuzzyResult['centroid'] ?? 0.0,
      base: fuzzyResult['base'] ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'ResultadoAvaliacao(categoriaId: $categoriaId, valor: ${valorFuzzyFinal.toStringAsFixed(2)}, interpretacao: $interpretacao)';
  }
}

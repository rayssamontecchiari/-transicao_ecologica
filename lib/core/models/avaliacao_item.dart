class AvaliacaoItem {
  final int id;
  final int avaliacaoId;
  final int indicadorId;
  final int valorLikert;
  final double? valorFuzzy;

  AvaliacaoItem({
    required this.id,
    required this.avaliacaoId,
    required this.indicadorId,
    required this.valorLikert,
    this.valorFuzzy,
  });
}

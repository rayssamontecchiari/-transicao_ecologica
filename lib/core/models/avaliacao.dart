class Avaliacao {
  final int id;
  final int familiaId;
  final DateTime data;
  final String avaliador;
  final String observacoes;

  Avaliacao({
    required this.id,
    required this.familiaId,
    required this.data,
    required this.avaliador,
    required this.observacoes,
  });
}

import 'package:flutter/material.dart';

import 'resultado_avaliacao_page.dart';

/// Compatibilidade: mantém a rota antiga, mas redireciona para a
/// única interface de resultados da avaliação.
class ResultadosAvaliacaoPage extends StatelessWidget {
  final int avaliacaoId;

  const ResultadosAvaliacaoPage({
    super.key,
    required this.avaliacaoId,
  });

  @override
  Widget build(BuildContext context) {
    return ResultadoAvaliacaoPage(avaliacaoId: avaliacaoId);
  }
}

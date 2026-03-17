import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column, Table;

import '../../core/database/app_database.dart';
import '../../core/services/resultado_avaliacao_service.dart';
import '../../core/models/resultado_avaliacao.dart';
import 'resultados_avaliacao_page.dart';

/// Página que exibe os detalhes de resultados de uma família específica
class FamiliaResultadosDetalhesPage extends StatefulWidget {
  final Familia familia;

  const FamiliaResultadosDetalhesPage({
    super.key,
    required this.familia,
  });

  @override
  State<FamiliaResultadosDetalhesPage> createState() =>
      _FamiliaResultadosDetalhesPageState();
}

class _FamiliaResultadosDetalhesPageState
    extends State<FamiliaResultadosDetalhesPage> {
  late AppDatabase _db;
  late ResultadoAvaliacaoService _resultadoService;

  bool _isLoading = true;
  List<_AvaliacaoComResultados> _avaliacoes = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _resultadoService = ResultadoAvaliacaoService(_db);

    // Obter todas as avaliações dessa família
    final avaliacoes = await (_db.select(_db.avaliacoes)
          ..where((a) => a.familiaId.equals(widget.familia.id))
          ..orderBy([
            (a) => OrderingTerm(expression: a.data, mode: OrderingMode.desc)
          ]))
        .get();

    List<_AvaliacaoComResultados> avaliacoesComResultados = [];

    for (final avaliacao in avaliacoes) {
      final stats =
          await _resultadoService.obterEstatisticasAvaliacao(avaliacao.id);

      avaliacoesComResultados.add(
        _AvaliacaoComResultados(
          avaliacao: avaliacao,
          media: stats.isNotEmpty ? stats['media'] as double? : null,
          minValor: stats.isNotEmpty ? stats['minValor'] as double? : null,
          maxValor: stats.isNotEmpty ? stats['maxValor'] as double? : null,
          resultados: stats.isNotEmpty
              ? stats['resultados'] as List<ResultadoAvaliacao>?
              : null,
        ),
      );
    }

    setState(() {
      _avaliacoes = avaliacoesComResultados;
      _isLoading = false;
    });
  }

  Color _obterCorPorValor(double? valor) {
    if (valor == null) return Colors.grey;
    if (valor >= 8.0) return Colors.green;
    if (valor >= 6.0) return Colors.blue;
    if (valor >= 4.0) return Colors.orange;
    if (valor >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  String _obterNomeCategoria(int categoriaId) {
    final map = {
      1: 'Campesinidade',
      2: 'Sustentabilidade',
      3: 'Organização Social',
      4: 'Agenciamento',
    };
    return map[categoriaId] ?? 'Categoria $categoriaId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados da Família'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _avaliacoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assessment_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma avaliação encontrada\npara ${widget.familia.nomeResponsavel}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cabeçalho com nome da família
                        Card(
                          elevation: 0,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Família',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.familia.nomeResponsavel,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Total de avaliações: ${_avaliacoes.length}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Lista de avaliações
                        ..._avaliacoes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return _buildAvaliacaoCard(context, index, item);
                        }).toList(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildAvaliacaoCard(
    BuildContext context,
    int index,
    _AvaliacaoComResultados item,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Avaliação #${_avaliacoes.length - index}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatarData(item.avaliacao.data),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (item.media != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _obterCorPorValor(item.media).withOpacity(0.2),
                      border: Border.all(color: _obterCorPorValor(item.media)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Média',
                          style: TextStyle(
                            fontSize: 10,
                            color: _obterCorPorValor(item.media),
                          ),
                        ),
                        Text(
                          item.media!.toStringAsFixed(2),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _obterCorPorValor(item.media),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Informações do avaliador
            Text(
              'Avaliador: ${item.avaliacao.avaliador}',
              style: const TextStyle(fontSize: 12),
            ),
            if (item.avaliacao.observacoes != null &&
                item.avaliacao.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Observações:',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.avaliacao.observacoes!,
                style: const TextStyle(fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            // Resultados por categoria
            if (item.resultados != null && item.resultados!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultados por Categoria',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...item.resultados!.map((resultado) {
                      final cor = _obterCorPorValor(resultado.valorFuzzyFinal);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _obterNomeCategoria(resultado.categoriaId),
                              style: const TextStyle(fontSize: 12),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cor.withOpacity(0.1),
                                border: Border.all(color: cor),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                resultado.valorFuzzyFinal.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: cor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Botão para ver detalhes completos
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResultadosAvaliacaoPage(
                        avaliacaoId: item.avaliacao.id,
                      ),
                    ),
                  );
                },
                child: const Text('Ver Detalhes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}

class _AvaliacaoComResultados {
  final Avaliacao avaliacao;
  final double? media;
  final double? minValor;
  final double? maxValor;
  final List<ResultadoAvaliacao>? resultados;

  _AvaliacaoComResultados({
    required this.avaliacao,
    required this.media,
    required this.minValor,
    required this.maxValor,
    required this.resultados,
  });
}

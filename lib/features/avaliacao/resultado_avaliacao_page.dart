import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/models/resultado_avaliacao.dart';
import '../../core/services/resultado_avaliacao_service.dart';
import '../../core/utils/natural_breaks_color_scale.dart';

/// Página única para exibir os resultados de uma avaliação.
class ResultadoAvaliacaoPage extends StatefulWidget {
  final int avaliacaoId;
  final FamiliaData? familia;

  const ResultadoAvaliacaoPage({
    super.key,
    required this.avaliacaoId,
    this.familia,
  });

  @override
  State<ResultadoAvaliacaoPage> createState() => _ResultadoAvaliacaoPageState();
}

class _ResultadoAvaliacaoPageState extends State<ResultadoAvaliacaoPage> {
  late AppDatabase _db;
  late ResultadoAvaliacaoService _resultadoService;
  NaturalBreaksColorScale _colorScale =
      NaturalBreaksColorScale.fromValues(const []);

  bool _isLoading = true;
  Map<String, dynamic> _estatisticas = {};
  List<ResultadoAvaliacao> _resultados = [];
  Map<int, CategoriaData> _categoriaMap = {};
  AvaliacaoData? _avaliacao;
  String? _nomeFamilia;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _resultadoService = ResultadoAvaliacaoService(_db);

    try {
      final avaliacao = await (_db.select(_db.avaliacao)
            ..where((a) => a.id.equals(widget.avaliacaoId)))
          .getSingleOrNull();

      FamiliaData? familia = widget.familia;
      if (familia == null && avaliacao != null) {
        familia = await (_db.select(_db.familia)
              ..where((f) => f.id.equals(avaliacao.familiaId)))
            .getSingleOrNull();
      }

      final estatisticas = await _resultadoService
          .obterEstatisticasAvaliacao(widget.avaliacaoId);
      final resultados =
          (estatisticas['resultados'] as List<ResultadoAvaliacao>?) ?? [];
      final categorias = await _db.select(_db.categoria).get();

      if (!mounted) return;

      setState(() {
        _avaliacao = avaliacao;
        _nomeFamilia = familia?.nomeResponsavel;
        _estatisticas = estatisticas;
        _resultados = resultados;
        _categoriaMap = {for (var cat in categorias) cat.id: cat};
        _colorScale = NaturalBreaksColorScale.fromValues(
          resultados.map((resultado) => resultado.valorFuzzyFinal).toList(),
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar resultados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _obterCorPorValor(double valor) => _colorScale.colorFor(valor);

  Color _obterCorNeutra() => Colors.grey.shade700;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resultados da Avaliação'),
            if ((_nomeFamilia ?? '').isNotEmpty)
              Text(
                _nomeFamilia!,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 0,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_avaliacao != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data: ${_formatarMesAno(_avaliacao!.data)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Avaliador: ${_avaliacao!.avaliador}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            Text(
                              'Resumo Geral',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if ((_nomeFamilia ?? '').isNotEmpty)
                              Text(
                                'Família: $_nomeFamilia',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_estatisticas.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              titulo: 'Média',
                              valor:
                                  '${(_estatisticas['media'] as double).toStringAsFixed(2)}',
                              cor: _obterCorNeutra(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              titulo: 'Mínima',
                              valor:
                                  '${(_estatisticas['minValor'] as double).toStringAsFixed(2)}',
                              cor: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              titulo: 'Máxima',
                              valor:
                                  '${(_estatisticas['maxValor'] as double).toStringAsFixed(2)}',
                              cor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      'Detalhamento por Categoria',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_resultados.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum resultado disponível',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Os dados da avaliação estão sendo processados.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._resultados.map((resultado) {
                        final categoria = _categoriaMap[resultado.categoriaId];
                        return _buildResultadoCard(resultado, categoria);
                      }),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultadoCard(
      ResultadoAvaliacao resultado, CategoriaData? categoria) {
    final cor = _obterCorNeutra();
    final nomeCate = categoria?.nome ?? 'Categoria ${resultado.categoriaId}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          initiallyExpanded: false,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  nomeCate,
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.2),
                  border: Border.all(color: cor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  resultado.valorFuzzyFinal.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          children: [
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
                    'Cálculo Fuzzy',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      'Centróide', resultado.centroid.toStringAsFixed(2)),
                  _buildDetailRow('Base', resultado.base.toStringAsFixed(2)),
                  _buildDetailRow('Soma A', resultado.sumA.toStringAsFixed(2)),
                  _buildDetailRow('Soma B', resultado.sumB.toStringAsFixed(2)),
                  _buildDetailRow('Soma C', resultado.sumC.toStringAsFixed(2)),
                  _buildDetailRow('Soma D', resultado.sumD.toStringAsFixed(2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatarMesAno(DateTime data) {
    final mes = data.month.toString().padLeft(2, '0');
    return '$mes/${data.year}';
  }
}

import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/resultado_avaliacao_service.dart';
import '../../core/models/resultado_avaliacao.dart';

/// Página que exibe os resultados das avaliações com cálculos fuzzy
class ResultadosAvaliacaoPage extends StatefulWidget {
  final int avaliacaoId;

  const ResultadosAvaliacaoPage({
    super.key,
    required this.avaliacaoId,
  });

  @override
  State<ResultadosAvaliacaoPage> createState() =>
      _ResultadosAvaliacaoPageState();
}

class _ResultadosAvaliacaoPageState extends State<ResultadosAvaliacaoPage> {
  late AppDatabase _db;
  late ResultadoAvaliacaoService _resultadoService;

  bool _isLoading = true;
  Map<String, dynamic> _estatisticas = {};
  Avaliacao? _avaliacao;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _resultadoService = ResultadoAvaliacaoService(_db);

    // Recuperar dados da avaliação
    final avaliacao = await (_db.select(_db.avaliacoes)
          ..where((a) => a.id.equals(widget.avaliacaoId)))
        .getSingleOrNull();

    // Calcular estatísticas
    final estatisticas =
        await _resultadoService.obterEstatisticasAvaliacao(widget.avaliacaoId);

    setState(() {
      _avaliacao = avaliacao;
      _estatisticas = estatisticas;
      _isLoading = false;
    });
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

  Color _obterCorPorValor(double valor) {
    if (valor >= 8.0) return Colors.green;
    if (valor >= 6.0) return Colors.blue;
    if (valor >= 4.0) return Colors.orange;
    if (valor >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados da Avaliação'),
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
                    // Cabeçalho
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
                                    'Data: ${_avaliacao!.data.toString().split(' ')[0]}',
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
                              'Resultados por Categoria',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Resumo geral
                    if (_estatisticas.isNotEmpty) ...[
                      Text(
                        'Resumo Geral',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              titulo: 'Média',
                              valor:
                                  '${(_estatisticas['media'] as double).toStringAsFixed(2)}',
                              cor: _obterCorPorValor(
                                  _estatisticas['media'] as double),
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

                    // Resultados por categoria
                    Text(
                      'Detalhamento por Categoria',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_estatisticas.isNotEmpty)
                      ...((_estatisticas['resultados']
                                  as List<ResultadoAvaliacao>?) ??
                              [])
                          .map((resultado) => _buildResultadoCard(resultado))
                          .toList(),

                    const SizedBox(height: 24),
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

  Widget _buildResultadoCard(ResultadoAvaliacao resultado) {
    final cor = _obterCorPorValor(resultado.valorFuzzyFinal);

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
                Text(
                  _obterNomeCategoria(resultado.categoriaId),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.2),
                    border: Border.all(color: cor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        resultado.valorFuzzyFinal.toStringAsFixed(2),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cor,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        resultado.interpretacao,
                        style: TextStyle(
                          fontSize: 10,
                          color: cor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Detalhes do cálculo fuzzy
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
                    'Centróide',
                    resultado.centroid.toStringAsFixed(4),
                  ),
                  _buildDetailRow(
                    'Base',
                    resultado.base.toStringAsFixed(4),
                  ),
                  _buildDetailRow(
                    'Soma D',
                    resultado.sumD.toStringAsFixed(4),
                  ),
                  _buildDetailRow(
                    'Soma A',
                    resultado.sumA.toStringAsFixed(4),
                  ),
                  _buildDetailRow(
                    'Soma B',
                    resultado.sumB.toStringAsFixed(4),
                  ),
                  _buildDetailRow(
                    'Soma C',
                    resultado.sumC.toStringAsFixed(4),
                  ),
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
}

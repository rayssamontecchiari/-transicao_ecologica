import 'dart:math';

import 'package:drift/drift.dart' hide Column, Table;
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/resultado_avaliacao_service.dart';
import '../../core/models/resultado_avaliacao.dart';
import 'iniciar_avaliacao_page.dart';

class ResultadosDashboardPage extends StatefulWidget {
  const ResultadosDashboardPage({super.key});

  @override
  State<ResultadosDashboardPage> createState() =>
      _ResultadosDashboardPageState();
}

class _ResultadosDashboardPageState extends State<ResultadosDashboardPage> {
  late AppDatabase _db;
  late ResultadoAvaliacaoService _resultadoService;
  bool _isLoading = true;
  int _familiasCadastradas = 0;
  int _avaliacoesRealizadas = 0;
  int _avaliacoesEmRascunho = 0;
  double _mediaGeral = 0.0;
  List<_AvaliacaoResumo> _evolucao = [];
  List<_CategoriaScore> _categorias = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _resultadoService = ResultadoAvaliacaoService(_db);

    final familias = await _db.select(_db.familia).get();
    final avaliacoes = await (_db.select(_db.avaliacao)
          ..orderBy([
            (a) => OrderingTerm(expression: a.data, mode: OrderingMode.asc)
          ]))
        .get();

    final avaliacoesConcluidas =
        avaliacoes.where((a) => a.status == 'completed').toList();

    final avaliacoesEmRascunho = avaliacoes.where((a) => a.status == 'draft');
    final categorias = await _db.select(_db.categoria).get();

    final categoriaMedia = <int, _CategoriaScore>{};
    final avaliacoesResumo = <_AvaliacaoResumo>[];

    for (final categoria in categorias) {
      categoriaMedia[categoria.id] = _CategoriaScore(
        categoriaId: categoria.id,
        nome: categoria.nome,
        totalValor: 0.0,
        quantidade: 0,
      );
    }

    double somaMedias = 0.0;
    int quantidadeMedias = 0;

    for (final avaliacao in avaliacoesConcluidas) {
      final stats =
          await _resultadoService.obterEstatisticasAvaliacao(avaliacao.id);
      if (stats.isEmpty || stats['media'] == null) {
        continue;
      }

      final media = stats['media'] as double;
      somaMedias += media;
      quantidadeMedias += 1;
      avaliacoesResumo.add(_AvaliacaoResumo(avaliacao.data, media));

      final resultados =
          (stats['resultados'] as List<ResultadoAvaliacao>?) ?? [];
      for (final resultado in resultados) {
        final score = categoriaMedia[resultado.categoriaId];
        if (score != null) {
          score.totalValor += resultado.valorFuzzyFinal;
          score.quantidade += 1;
        }
      }
    }

    setState(() {
      _familiasCadastradas = familias.length;
      _avaliacoesRealizadas = avaliacoes.length;
      _avaliacoesEmRascunho = avaliacoesEmRascunho.length;
      _mediaGeral = quantidadeMedias > 0 ? somaMedias / quantidadeMedias : 0.0;
      _evolucao = avaliacoesResumo;
      _categorias = categoriaMedia.values.toList();
      _isLoading = false;
    });
  }

  Color _corPorValor(double valor) {
    if (valor >= 8.0) return Colors.green;
    if (valor >= 6.0) return Colors.blue;
    if (valor >= 4.0) return Colors.orange;
    if (valor >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados e Dashboard'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _init,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummaryRow(theme),
                    const SizedBox(height: 18),
                    if (_avaliacoesEmRascunho > 0) _buildDraftCard(theme),
                    const SizedBox(height: 18),
                    _buildEvolutionCard(theme),
                    const SizedBox(height: 18),
                    _buildCategoryScoresCard(theme),
                    const SizedBox(height: 18),
                    _buildRecentEvaluationsCard(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme) {
    return Row(
      children: [
        _buildMetricCard(
          title: 'Famílias',
          value: _familiasCadastradas.toString(),
          color: Colors.green,
          theme: theme,
        ),
        _buildMetricCard(
          title: 'Avaliações',
          value: _avaliacoesRealizadas.toString(),
          color: Colors.blue,
          theme: theme,
        ),
        _buildMetricCard(
          title: 'Média Geral',
          value: _mediaGeral.isNaN ? '--' : _mediaGeral.toStringAsFixed(1),
          color: Colors.amber.shade700,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.bodySmall),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Avaliações em Rascunho',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Há $_avaliacoesEmRascunho avaliações ainda não finalizadas. Continue o fluxo para salvar seus resultados.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const IniciarAvaliacaoPage(),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Continuar Avaliação'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvolutionCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Evolução dos Resultados',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_evolucao.isEmpty)
              Text(
                'Nenhuma avaliação concluída ainda para exibir a evolução.',
                style: theme.textTheme.bodyMedium,
              )
            else ...[
              Text(
                'Últimas ${_evolucao.length} avaliações',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: SparklineChart(
                  values: _evolucao.map((item) => item.media).toList(),
                  lineColor: Colors.green.shade700,
                  fillColor: Colors.green.withOpacity(0.12),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _evolucao
                    .map(
                      (item) => Chip(
                        label: Text(
                          '${_formatDate(item.date)}: ${item.media.toStringAsFixed(1)}',
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryScoresCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pontuação por Categoria',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_categorias.isEmpty)
              Text('Ainda não há dados suficientes para calcular pontuação.',
                  style: theme.textTheme.bodyMedium)
            else
              Column(
                children: _categorias.map((item) {
                  final average = item.quantidade > 0
                      ? item.totalValor / item.quantidade
                      : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(item.nome)),
                        const SizedBox(width: 10),
                        Text(
                          average.isNaN ? '--' : average.toStringAsFixed(2),
                          style: TextStyle(
                            color: _corPorValor(average),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEvaluationsCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Últimas Avaliações',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_evolucao.isEmpty)
              Text('Nenhuma avaliação concluída encontrada.',
                  style: theme.textTheme.bodyMedium)
            else
              Column(
                children: _evolucao.reversed
                    .take(5)
                    .map((item) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(_formatDate(item.date)),
                          trailing: Text(
                            item.media.toStringAsFixed(2),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _corPorValor(item.media),
                            ),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class SparklineChart extends StatelessWidget {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  const SparklineChart({
    super.key,
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _SparklinePainter(values, lineColor, fillColor),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  _SparklinePainter(this.values, this.lineColor, this.fillColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paintLine = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()..color = fillColor;
    final paintDot = Paint()..color = lineColor;

    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final range = max(maxValue - minValue, 1.0);

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < values.length; i++) {
      final x =
          i * (size.width / (values.length - 1).clamp(1, values.length - 1));
      final normalized = (values[i] - minValue) / range;
      final y = size.height - (normalized * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, paintDot);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

class _AvaliacaoResumo {
  final DateTime date;
  final double media;

  _AvaliacaoResumo(this.date, this.media);
}

class _CategoriaScore {
  final int categoriaId;
  final String nome;
  double totalValor;
  int quantidade;

  _CategoriaScore({
    required this.categoriaId,
    required this.nome,
    required this.totalValor,
    required this.quantidade,
  });
}

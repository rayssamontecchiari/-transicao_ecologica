import 'dart:math';

import 'package:drift/drift.dart' hide Column, Table;
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/resultado_avaliacao_service.dart';
import '../../core/models/resultado_avaliacao.dart';

enum _ResultadoViewMode {
  geral,
  categoria,
}

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
  double _mediaGeral = 0.0;
  double _chartMin = 0.0;
  double _chartMax = 0.0;
  List<AvaliacaoData> _allAvaliacoes = [];
  List<FamiliaData> _familias = [];
  List<RegiaoData> _regioes = [];
  List<CategoriaData> _categoriasData = [];
  int? _selectedFamiliaId;
  int? _selectedRegiaoId;
  DateTime? _startDate;
  DateTime? _endDate;
  _ResultadoViewMode _viewMode = _ResultadoViewMode.geral;
  int? _selectedCategoriaId;
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
    final regioes = await _db.select(_db.regiao).get();
    final categoriasData = await _db.select(_db.categoria).get();
    final avaliacoes = await (_db.select(_db.avaliacao)
          ..orderBy([
            (a) => OrderingTerm(expression: a.data, mode: OrderingMode.asc)
          ]))
        .get();

    setState(() {
      _familias = familias;
      _regioes = regioes;
      _categoriasData = categoriasData;
      _allAvaliacoes = avaliacoes;
      _selectedCategoriaId ??=
          categoriasData.isNotEmpty ? categoriasData.first.id : null;
    });

    await _applyFilters();
  }

  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
    });

    final avaliacoesConcluidas =
        _allAvaliacoes.where((a) => a.status == 'completed').toList();
    final avaliacoesFiltradas = avaliacoesConcluidas.where((avaliacao) {
      if (_selectedFamiliaId != null &&
          avaliacao.familiaId != _selectedFamiliaId) {
        return false;
      }

      if (_selectedRegiaoId != null) {
        final familiasMatch =
            _familias.where((f) => f.id == avaliacao.familiaId).toList();
        if (familiasMatch.isEmpty ||
            familiasMatch.first.regiaoId != _selectedRegiaoId) {
          return false;
        }
      }

      if (_startDate != null && avaliacao.data.isBefore(_startDate!)) {
        return false;
      }

      if (_endDate != null && avaliacao.data.isAfter(_endDate!)) {
        return false;
      }

      return true;
    }).toList();

    final categoriaMedia = <int, _CategoriaScore>{};
    for (final categoria in _categoriasData) {
      categoriaMedia[categoria.id] = _CategoriaScore(
        categoriaId: categoria.id,
        nome: categoria.nome,
        totalValor: 0.0,
        quantidade: 0,
      );
    }

    final avaliacoesResumo = <_AvaliacaoResumo>[];

    for (final avaliacao in avaliacoesFiltradas) {
      final stats =
          await _resultadoService.obterEstatisticasAvaliacao(avaliacao.id);
      if (stats.isEmpty) {
        continue;
      }

      final resultados =
          (stats['resultados'] as List<ResultadoAvaliacao>?) ?? [];
      for (final resultado in resultados) {
        final score = categoriaMedia[resultado.categoriaId];
        if (score != null) {
          score.totalValor += resultado.valorFuzzyFinal;
          score.quantidade += 1;
        }
      }

      if (_viewMode == _ResultadoViewMode.geral) {
        final media = stats['media'] as double?;
        if (media == null) {
          continue;
        }

        avaliacoesResumo.add(_AvaliacaoResumo(avaliacao.data, media));
      } else {
        final categoriaId = _selectedCategoriaId;
        if (categoriaId == null) {
          continue;
        }

        final categoriaResultados = resultados
            .where((resultado) => resultado.categoriaId == categoriaId)
            .toList();
        if (categoriaResultados.isEmpty) {
          continue;
        }

        final valor = categoriaResultados.first.valorFuzzyFinal;
        avaliacoesResumo.add(_AvaliacaoResumo(avaliacao.data, valor));
      }
    }

    final valoresResumo = avaliacoesResumo.map((item) => item.media).toList();
    final mediaAtual = valoresResumo.isNotEmpty
        ? valoresResumo.reduce((a, b) => a + b) / valoresResumo.length
        : 0.0;
    final minAtual = valoresResumo.isNotEmpty
        ? valoresResumo.reduce((a, b) => a < b ? a : b)
        : 0.0;
    final maxAtual = valoresResumo.isNotEmpty
        ? valoresResumo.reduce((a, b) => a > b ? a : b)
        : 0.0;

    setState(() {
      _mediaGeral = mediaAtual;
      _chartMin = minAtual;
      _chartMax = maxAtual;
      _evolucao = avaliacoesResumo;
      _categorias = categoriaMedia.values.toList();
      _isLoading = false;
    });
  }

  String _nomeFamilia(int? id) {
    if (id == null) return 'Todas as famílias';
    final familia = _familias.where((f) => f.id == id).toList();
    return familia.isNotEmpty
        ? familia.first.nomeResponsavel
        : 'Família desconhecida';
  }

  String _nomeRegiao(int? id) {
    if (id == null) return 'Todas as regiões';
    final regiao = _regioes.where((r) => r.id == id).toList();
    return regiao.isNotEmpty ? regiao.first.nome : 'Região desconhecida';
  }

  String _nomeCategoria(int? id) {
    if (id == null) return 'Todas as categorias';
    final categoria = _categoriasData.where((c) => c.id == id).toList();
    return categoria.isNotEmpty
        ? categoria.first.nome
        : 'Categoria desconhecida';
  }

  String _periodoLabel() {
    if (_startDate == null && _endDate == null) {
      return 'Período: todo o histórico';
    }

    final inicio = _startDate != null ? _formatDate(_startDate!) : 'início';
    final fim = _endDate != null ? _formatDate(_endDate!) : 'presente';
    return 'Período: $inicio até $fim';
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate =
        isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final firstDate = DateTime(2000);
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = picked;
        if (_startDate != null && _startDate!.isAfter(_endDate!)) {
          _startDate = _endDate;
        }
      }
    });

    await _applyFilters();
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedFamiliaId = null;
      _selectedRegiaoId = null;
      _startDate = null;
      _endDate = null;
      _viewMode = _ResultadoViewMode.geral;
      _selectedCategoriaId =
          _categoriasData.isNotEmpty ? _categoriasData.first.id : null;
    });
    await _applyFilters();
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
                    _buildFilterCard(theme),
                    const SizedBox(height: 18),
                    _buildEvolutionCard(theme),
                    const SizedBox(height: 18),
                    _buildCategoryScoresCard(theme),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
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

  Widget _buildEvolutionCard(ThemeData theme) {
    final viewLabel = _viewMode == _ResultadoViewMode.geral
        ? 'Resultado geral'
        : 'Categoria: ${_nomeCategoria(_selectedCategoriaId)}';
    final filterLabel =
        '${_nomeFamilia(_selectedFamiliaId)} • ${_nomeRegiao(_selectedRegiaoId)}';

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
            const SizedBox(height: 8),
            Text(viewLabel, style: theme.textTheme.bodySmall),
            Text(_periodoLabel(), style: theme.textTheme.bodySmall),
            Text(filterLabel, style: theme.textTheme.bodySmall),
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mín: ${_chartMin.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall),
                  Text('Média: ${_mediaGeral.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary)),
                  Text('Máx: ${_chartMax.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: SparklineChart(
                  values: _evolucao.map((item) => item.media).toList(),
                  lineColor: Colors.green.shade700,
                  fillColor: Colors.green.withOpacity(0.12),
                  xLabels: _evolucao.isNotEmpty
                      ? [
                          _formatDate(_evolucao.first.date),
                          _formatDate(_evolucao.last.date),
                        ]
                      : [],
                  yLabels: [
                    _chartMax.toStringAsFixed(1),
                    _mediaGeral.toStringAsFixed(1),
                    _chartMin.toStringAsFixed(1),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
              'Pontuação Média por Categoria',
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

  Widget _buildFilterCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filtros de resultado',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Geral'),
                  selected: _viewMode == _ResultadoViewMode.geral,
                  onSelected: (_) async {
                    setState(() => _viewMode = _ResultadoViewMode.geral);
                    await _applyFilters();
                  },
                ),
                ChoiceChip(
                  label: const Text('Por categoria'),
                  selected: _viewMode == _ResultadoViewMode.categoria,
                  onSelected: (_) async {
                    setState(() => _viewMode = _ResultadoViewMode.categoria);
                    await _applyFilters();
                  },
                ),
              ],
            ),
            if (_viewMode == _ResultadoViewMode.categoria) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                isExpanded: true,
                value: _selectedCategoriaId,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: [
                  if (_categoriasData.isNotEmpty)
                    ..._categoriasData.map(
                      (cat) => DropdownMenuItem<int?>(
                        value: cat.id,
                        child: Text(
                          cat.nome,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
                onChanged: (value) async {
                  setState(() => _selectedCategoriaId = value);
                  await _applyFilters();
                },
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              value: _selectedFamiliaId,
              decoration: const InputDecoration(
                labelText: 'Família',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todas as famílias'),
                ),
                ..._familias.map(
                  (familia) => DropdownMenuItem<int?>(
                    value: familia.id,
                    child: Text(
                      familia.nomeResponsavel,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) async {
                setState(() {
                  _selectedFamiliaId = value;
                  _selectedRegiaoId = value == null
                      ? null
                      : _familias.firstWhere((f) => f.id == value).regiaoId;
                });
                await _applyFilters();
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              value: _selectedRegiaoId,
              decoration: InputDecoration(
                labelText: 'Região',
                border: const OutlineInputBorder(),
                helperText: _selectedFamiliaId != null
                    ? 'Região definida pela família selecionada'
                    : null,
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todas as regiões'),
                ),
                ..._regioes.map(
                  (regiao) => DropdownMenuItem<int?>(
                    value: regiao.id,
                    child: Text(
                      regiao.nome,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: _selectedFamiliaId == null
                  ? (value) async {
                      setState(() => _selectedRegiaoId = value);
                      await _applyFilters();
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(isStart: true),
                    child: Text(
                      _startDate != null
                          ? 'Início: ${_formatDate(_startDate!)}'
                          : 'Data de início',
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(isStart: false),
                    child: Text(
                      _endDate != null
                          ? 'Fim: ${_formatDate(_endDate!)}'
                          : 'Data de fim',
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            if (_startDate != null ||
                _endDate != null ||
                _selectedFamiliaId != null ||
                _selectedRegiaoId != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Limpar filtros'),
                  ),
                ),
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
  final List<String> xLabels;
  final List<String> yLabels;

  const SparklineChart({
    super.key,
    required this.values,
    required this.lineColor,
    required this.fillColor,
    this.xLabels = const [],
    this.yLabels = const [],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:
          _SparklinePainter(values, lineColor, fillColor, xLabels, yLabels),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final List<String> xLabels;
  final List<String> yLabels;

  _SparklinePainter(
      this.values, this.lineColor, this.fillColor, this.xLabels, this.yLabels);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const leftPadding = 40.0;
    const bottomPadding = 28.0;
    const topPadding = 12.0;
    const rightPadding = 12.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final axisPaint = Paint()
      ..color = lineColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

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

    final startX = leftPadding;
    final startY = topPadding + chartHeight;

    for (var i = 0; i < values.length; i++) {
      final x = startX +
          (i * (chartWidth / (values.length - 1).clamp(1, values.length - 1)));
      final normalized = (values[i] - minValue) / range;
      final y = topPadding + chartHeight - (normalized * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, startY);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, paintDot);
    }

    fillPath.lineTo(startX + chartWidth, startY);
    fillPath.close();

    canvas.drawLine(
        Offset(startX, topPadding), Offset(startX, startY), axisPaint);
    canvas.drawLine(
        Offset(startX, startY), Offset(startX + chartWidth, startY), axisPaint);

    for (var labelIndex = 0; labelIndex < yLabels.length; labelIndex++) {
      final label = yLabels[labelIndex];
      final y = topPadding + (chartHeight * labelIndex / (yLabels.length - 1));
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: lineColor.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(
              leftPadding - textPainter.width - 8, y - textPainter.height / 2));

      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + chartWidth, y),
        axisPaint..strokeWidth = 0.5,
      );
    }

    if (xLabels.isNotEmpty) {
      for (var i = 0; i < xLabels.length; i++) {
        final label = xLabels[i];
        final x = startX +
            (i *
                chartWidth /
                (xLabels.length - 1).clamp(1, xLabels.length - 1));
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: lineColor.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: rightPadding + 60);
        textPainter.paint(
            canvas, Offset(x - textPainter.width / 2, startY + 4));
      }
    }

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

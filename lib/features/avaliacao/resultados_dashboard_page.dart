import 'dart:math';

import 'package:drift/drift.dart' hide Column, Table;
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/models/resultado_avaliacao.dart';
import '../../core/services/resultado_avaliacao_service.dart';

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
  List<ComunidadeData> _comunidades = [];
  List<CategoriaData> _categoriasData = [];

  int? _selectedFamiliaId;
  int? _selectedComunidadeId;
  DateTime? _startDate;
  DateTime? _endDate;
  _ResultadoViewMode _viewMode = _ResultadoViewMode.geral;
  int? _selectedCategoriaId;

  List<_AvaliacaoResumo> _evolucao = [];
  List<_CategoriaScore> _categorias = [];
  List<_FamiliaComparacao> _comparacaoFamilias = [];
  List<_EvolucaoFamilia> _evolucaoFamilias = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _resultadoService = ResultadoAvaliacaoService(_db);

    final familias = await _db.select(_db.familia).get();
    final comunidades = await _db.select(_db.comunidade).get();
    final categoriasData = await _db.select(_db.categoria).get();
    final avaliacoes = await (_db.select(_db.avaliacao)
          ..orderBy([
            (a) => OrderingTerm(expression: a.data, mode: OrderingMode.asc),
          ]))
        .get();

    setState(() {
      _familias = familias;
      _comunidades = comunidades;
      _categoriasData = categoriasData;
      _allAvaliacoes = avaliacoes;
      _selectedCategoriaId ??=
          categoriasData.isNotEmpty ? categoriasData.first.id : null;
    });

    await _applyFilters();
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    final avaliacoesConcluidas =
        _allAvaliacoes.where((a) => a.status == 'completed').toList();

    final avaliacoesFiltradas = avaliacoesConcluidas.where((avaliacao) {
      if (_selectedFamiliaId != null &&
          avaliacao.familiaId != _selectedFamiliaId) {
        return false;
      }

      if (_selectedComunidadeId != null) {
        final familia = _familias.where((f) => f.id == avaliacao.familiaId);
        if (familia.isEmpty ||
            familia.first.comunidadeId != _selectedComunidadeId) {
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
    final comparacaoBuilders = <int, _FamiliaComparacaoBuilder>{};

    for (final avaliacao in avaliacoesFiltradas) {
      final stats =
          await _resultadoService.obterEstatisticasAvaliacao(avaliacao.id);
      if (stats.isEmpty) {
        continue;
      }

      final resultados =
          (stats['resultados'] as List<ResultadoAvaliacao>?) ?? [];
      final media = stats['media'] as double?;

      for (final resultado in resultados) {
        final score = categoriaMedia[resultado.categoriaId];
        if (score != null) {
          score.totalValor += resultado.valorFuzzyFinal;
          score.quantidade += 1;
        }
      }

      final familiaId = avaliacao.familiaId;
      final builder = comparacaoBuilders.putIfAbsent(
        familiaId,
        () => _FamiliaComparacaoBuilder(
          familiaId: familiaId,
          familiaNome: _nomeFamilia(familiaId),
        ),
      );

      if (media != null) {
        builder.addMedia(avaliacao.data, media);
      }
      for (final resultado in resultados) {
        builder.addCategoria(resultado.categoriaId, resultado.valorFuzzyFinal);
      }

      if (_viewMode == _ResultadoViewMode.geral) {
        if (media != null) {
          avaliacoesResumo.add(_AvaliacaoResumo(avaliacao.data, media));
        }
      } else {
        final categoriaId = _selectedCategoriaId;
        if (categoriaId != null) {
          final categoriaResultados = resultados
              .where((resultado) => resultado.categoriaId == categoriaId)
              .toList();
          if (categoriaResultados.isNotEmpty) {
            avaliacoesResumo.add(
              _AvaliacaoResumo(
                avaliacao.data,
                categoriaResultados.first.valorFuzzyFinal,
              ),
            );
          }
        }
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

    final comparacaoFamilias = comparacaoBuilders.values
        .map((builder) => builder.build(_categoriasData))
        .toList()
      ..sort((a, b) => b.mediaFinal.compareTo(a.mediaFinal));

    final evolucaoFamilias = comparacaoBuilders.values
        .where((builder) => builder.series.length >= 2)
        .map((builder) {
      final serie = [...builder.series]
        ..sort((a, b) => a.date.compareTo(b.date));
      final inicio = serie.first;
      final fim = serie.last;
      return _EvolucaoFamilia(
        familiaId: builder.familiaId,
        familiaNome: builder.familiaNome,
        inicio: inicio,
        fim: fim,
        variacao: fim.media - inicio.media,
        quantidadeAvaliacoes: serie.length,
      );
    }).toList()
      ..sort((a, b) => b.variacao.compareTo(a.variacao));

    setState(() {
      _mediaGeral = mediaAtual;
      _chartMin = minAtual;
      _chartMax = maxAtual;
      _evolucao = avaliacoesResumo;
      _categorias = categoriaMedia.values.toList();
      _comparacaoFamilias = comparacaoFamilias;
      _evolucaoFamilias = evolucaoFamilias;
      _isLoading = false;
    });
  }

  Future<void> _showFilterBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> update(VoidCallback change) async {
              setState(change);
              setModalState(() {});
              await _applyFilters();
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Filtros',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Geral'),
                            selected: _viewMode == _ResultadoViewMode.geral,
                            onSelected: (_) async {
                              await update(() {
                                _viewMode = _ResultadoViewMode.geral;
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Por categoria'),
                            selected: _viewMode == _ResultadoViewMode.categoria,
                            onSelected: (_) async {
                              await update(() {
                                _viewMode = _ResultadoViewMode.categoria;
                                _selectedCategoriaId ??= _categoriasData.isEmpty
                                    ? null
                                    : _categoriasData.first.id;
                              });
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
                          items: _categoriasData
                              .map(
                                (cat) => DropdownMenuItem<int?>(
                                  value: cat.id,
                                  child: Text(
                                    cat.nome,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) async {
                            await update(() => _selectedCategoriaId = value);
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
                          await update(() {
                            _selectedFamiliaId = value;
                            _selectedComunidadeId = value == null
                                ? null
                                : _familias
                                    .firstWhere((f) => f.id == value)
                                    .comunidadeId;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int?>(
                        isExpanded: true,
                        value: _selectedComunidadeId,
                        decoration: InputDecoration(
                          labelText: 'Comunidade',
                          border: const OutlineInputBorder(),
                          helperText: _selectedFamiliaId != null
                              ? 'Comunidade definida pela família selecionada'
                              : null,
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Todas as comunidades'),
                          ),
                          ..._comunidades.map(
                            (comunidade) => DropdownMenuItem<int?>(
                              value: comunidade.id,
                              child: Text(
                                comunidade.nome,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: _selectedFamiliaId == null
                            ? (value) async {
                                await update(
                                    () => _selectedComunidadeId = value);
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _selectMonthYear(isStart: true),
                              icon: const Icon(Icons.calendar_month),
                              label: Text(
                                _startDate == null
                                    ? 'Mês inicial'
                                    : _formatMonthYear(_startDate!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _selectMonthYear(isStart: false),
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _endDate == null
                                    ? 'Mês final'
                                    : _formatMonthYear(_endDate!),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            await update(() {
                              _selectedFamiliaId = null;
                              _selectedComunidadeId = null;
                              _startDate = null;
                              _endDate = null;
                              _viewMode = _ResultadoViewMode.geral;
                              _selectedCategoriaId = _categoriasData.isEmpty
                                  ? null
                                  : _categoriasData.first.id;
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpar filtros'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectMonthYear({required bool isStart}) async {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    final baseDate =
        isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());

    final years = List.generate(31, (index) => 2000 + index);

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) {
        var mesSelecionado = baseDate.month;
        var anoSelecionado = baseDate.year;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isStart ? 'Mês inicial' : 'Mês final'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: mesSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Mês',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      meses.length,
                      (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(meses[index]),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() => mesSelecionado = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: anoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Ano',
                      border: OutlineInputBorder(),
                    ),
                    items: years
                        .map(
                          (year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text('$year'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() => anoSelecionado = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    {'mes': mesSelecionado, 'ano': anoSelecionado},
                  ),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    setState(() {
      final month = result['mes']!;
      final year = result['ano']!;
      if (isStart) {
        _startDate = DateTime(year, month, 1);
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = DateTime(year, month + 1, 0, 23, 59, 59);
        }
      } else {
        _endDate = DateTime(year, month + 1, 0, 23, 59, 59);
        if (_startDate != null && _startDate!.isAfter(_endDate!)) {
          _startDate = DateTime(year, month, 1);
        }
      }
    });

    await _applyFilters();
  }

  String _nomeFamilia(int? id) {
    if (id == null) return 'Todas as famílias';
    final familia = _familias.where((f) => f.id == id).toList();
    return familia.isNotEmpty
        ? familia.first.nomeResponsavel
        : 'Família desconhecida';
  }

  String _nomeComunidade(int? id) {
    if (id == null) return 'Todas as comunidades';
    final comunidade = _comunidades.where((c) => c.id == id).toList();
    return comunidade.isNotEmpty
        ? comunidade.first.nome
        : 'Comunidade desconhecida';
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

    final inicio =
        _startDate != null ? _formatMonthYear(_startDate!) : 'início';
    final fim = _endDate != null ? _formatMonthYear(_endDate!) : 'presente';
    return 'Período: $inicio até $fim';
  }

  bool _hasActiveFilters() {
    return _selectedFamiliaId != null ||
        _selectedComunidadeId != null ||
        _startDate != null ||
        _endDate != null ||
        _viewMode == _ResultadoViewMode.categoria;
  }

  _IndiceClasse _classificarIndice(double valor) {
    if (valor >= 0.8) {
      return const _IndiceClasse('Muito bom', Color(0xFF2E7D32));
    }
    if (valor >= 0.6) {
      return const _IndiceClasse('Bom', Color(0xFF689F38));
    }
    if (valor >= 0.4) {
      return const _IndiceClasse('Regular', Color(0xFFF9A825));
    }
    if (valor >= 0.2) {
      return const _IndiceClasse('Ruim', Color(0xFFEF6C00));
    }
    return const _IndiceClasse('Muito ruim', Color(0xFFC62828));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _buildHeaderCard(theme),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final totalWidth = constraints.maxWidth;
                          final sideTabWidth = totalWidth * 0.27;
                          final middleTabWidth = totalWidth * 0.46;

                          return TabBar(
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelPadding: EdgeInsets.zero,
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelColor: theme.colorScheme.onPrimary,
                            unselectedLabelColor:
                                theme.colorScheme.onSurfaceVariant,
                            tabs: [
                              SizedBox(
                                width: sideTabWidth,
                                child: const Tab(text: 'Geral'),
                              ),
                              SizedBox(
                                width: middleTabWidth,
                                child: const Tab(text: 'Comparação'),
                              ),
                              SizedBox(
                                width: sideTabWidth,
                                child: const Tab(text: 'Evolução'),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildVisaoGeralTab(theme),
                        _buildComparacaoTab(theme),
                        _buildEvolucaoTab(theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildVisaoGeralTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _init,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          _buildMelhorPiorFamiliaCard(theme),
          const SizedBox(height: 14),
          _buildEvolutionCard(theme),
          const SizedBox(height: 14),
          _buildCategoryScoresCard(theme),
        ],
      ),
    );
  }

  Widget _buildComparacaoTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _init,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          _buildComparacaoMediaFinalChartCard(theme),
          const SizedBox(height: 14),
          _buildComparacaoFamiliasCard(theme),
        ],
      ),
    );
  }

  Widget _buildEvolucaoTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _init,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          _buildEvolucaoFamiliasCard(theme),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _showFilterBottomSheet,
              icon: const Icon(Icons.filter_list),
              label: const Text(
                'Abrir filtros',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: _hasActiveFilters()
                  ? () async {
                      setState(() {
                        _selectedFamiliaId = null;
                        _selectedComunidadeId = null;
                        _startDate = null;
                        _endDate = null;
                        _viewMode = _ResultadoViewMode.geral;
                        _selectedCategoriaId = _categoriasData.isEmpty
                            ? null
                            : _categoriasData.first.id;
                      });
                      await _applyFilters();
                    }
                  : null,
              icon: const Icon(Icons.clear),
              label: const Text(
                'Limpar filtros',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.onSurface,
                disabledBackgroundColor: Colors.white,
                disabledForegroundColor:
                    theme.colorScheme.onSurface.withOpacity(0.38),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMelhorPiorFamiliaCard(ThemeData theme) {
    if (_comparacaoFamilias.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Sem dados para destacar melhor e pior família no período selecionado.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final melhor = _comparacaoFamilias.first;
    final pior = _comparacaoFamilias.last;

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Melhor x pior família avaliada',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildResumoFamiliaExtremo(
                theme,
                title: 'Melhor avaliada',
                familia: melhor,
                color: Colors.green.shade700,
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 10),
              _buildResumoFamiliaExtremo(
                theme,
                title: 'Pior avaliada',
                familia: pior,
                color: Colors.red.shade700,
                icon: Icons.trending_down,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumoFamiliaExtremo(
    ThemeData theme, {
    required String title,
    required _FamiliaComparacao familia,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  familia.familiaNome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            familia.mediaFinal.toStringAsFixed(2),
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionCard(ThemeData theme) {
    final viewLabel = _viewMode == _ResultadoViewMode.geral
        ? 'Resultado geral'
        : 'Categoria: ${_nomeCategoria(_selectedCategoriaId)}';

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Evolução geral',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(viewLabel, style: theme.textTheme.bodySmall),
              Text(_periodoLabel(), style: theme.textTheme.bodySmall),
              const SizedBox(height: 10),
              if (_evolucao.isEmpty)
                Text(
                  'Nenhuma avaliação concluída no período.',
                  style: theme.textTheme.bodyMedium,
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mín: ${_chartMin.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall),
                    Text(
                      'Média: ${_mediaGeral.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text('Máx: ${_chartMax.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 180,
                  child: SparklineChart(
                    values: _evolucao.map((item) => item.media).toList(),
                    lineColor: Colors.green.shade700,
                    fillColor: Colors.green.withOpacity(0.12),
                    xLabels: _evolucao.isNotEmpty
                        ? [
                            _formatMonthYear(_evolucao.first.date),
                            _formatMonthYear(_evolucao.last.date),
                          ]
                        : [],
                    yLabels: [
                      _chartMax.toStringAsFixed(1),
                      _mediaGeral.toStringAsFixed(1),
                      _chartMin.toStringAsFixed(1),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryScoresCard(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Índices médios por categoria',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_categorias.isEmpty)
                Text(
                  'Ainda não há dados suficientes para cálculo.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                Column(
                  children: _categorias.map((item) {
                    final average = item.quantidade > 0
                        ? item.totalValor / item.quantidade
                        : 0.0;
                    final classe = _classificarIndice(average);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.nome,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            average.toStringAsFixed(2),
                            style: TextStyle(
                              color: classe.color,
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
      ),
    );
  }

  Widget _buildComparacaoFamiliasCard(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Comparação por família',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Cada família mostra 4 categorias + média final.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              if (_comparacaoFamilias.isEmpty)
                Text(
                  'Sem dados no período selecionado.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                Column(
                  children: _comparacaoFamilias.map((familia) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              familia.familiaNome,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ...familia.barras.map((barra) {
                              final classe = _classificarIndice(barra.valor);
                              return _HorizontalIndiceBar(
                                label: barra.label,
                                value: barra.valor,
                                color: classe.color,
                                labelWidth: 170,
                                barWidthRatio: 0.38,
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparacaoMediaFinalChartCard(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Famílias por resultado final',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_comparacaoFamilias.isEmpty)
                Text(
                  'Sem dados no período selecionado.',
                  style: theme.textTheme.bodyMedium,
                )
              else ...[
                Column(
                  children: _comparacaoFamilias.map((familia) {
                    final classe = _classificarIndice(familia.mediaFinal);
                    return _HorizontalIndiceBar(
                      label: familia.familiaNome,
                      value: familia.mediaFinal,
                      color: classe.color,
                      labelWidth: 180,
                      barWidthRatio: 0.38,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvolucaoFamiliasCard(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Evolução das famílias',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_evolucaoFamilias.isEmpty)
                Text(
                  'São necessárias ao menos 2 avaliações por família no período.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                Column(
                  children: _evolucaoFamilias.map((item) {
                    final inicioExibicao = _roundTo2(item.inicio.media);
                    final fimExibicao = _roundTo2(item.fim.media);
                    final variacaoExibicao =
                        _roundTo2(fimExibicao - inicioExibicao);
                    final cor =
                        variacaoExibicao >= 0 ? Colors.green : Colors.red;
                    final sinal = variacaoExibicao >= 0 ? '+' : '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.familiaNome,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatMonthYear(item.inicio.date)} ${inicioExibicao.toStringAsFixed(2)} → ${_formatMonthYear(item.fim.date)} ${fimExibicao.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$sinal${variacaoExibicao.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: cor,
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
      ),
    );
  }

  double _roundTo2(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  String _formatMonthYear(DateTime date) {
    final mes = date.month.toString().padLeft(2, '0');
    return '$mes/${date.year}';
  }
}

class _HorizontalIndiceBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double labelWidth;
  final double barWidthRatio;

  const _HorizontalIndiceBar({
    required this.label,
    required this.value,
    required this.color,
    this.labelWidth = 78,
    this.barWidthRatio = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalLabelWidth =
            labelWidth.clamp(110.0, constraints.maxWidth * 0.72);
        final totalBarWidth = constraints.maxWidth - totalLabelWidth - 48;
        final barWidth =
            (totalBarWidth * barWidthRatio).clamp(50.0, totalBarWidth);
        final filledWidth = barWidth * clamped;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: totalLabelWidth,
                child: Text(
                  label,
                  maxLines: 3,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        height: 1.2,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: barWidth,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(
                        height: 14,
                        color: Colors.grey.shade200,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: filledWidth,
                        height: 14,
                        color: color.withOpacity(0.85),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  clamped.toStringAsFixed(2),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
    this.values,
    this.lineColor,
    this.fillColor,
    this.xLabels,
    this.yLabels,
  );

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
    final valueSteps = values.length > 1 ? values.length - 1 : 1;

    for (var i = 0; i < values.length; i++) {
      final x = startX + (i * (chartWidth / valueSteps));
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
      Offset(startX, startY),
      Offset(startX + chartWidth, startY),
      axisPaint,
    );

    final yLabelSteps = yLabels.length > 1 ? yLabels.length - 1 : 1;
    for (var labelIndex = 0; labelIndex < yLabels.length; labelIndex++) {
      final label = yLabels[labelIndex];
      final y = topPadding + (chartHeight * labelIndex / yLabelSteps);
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
        Offset(leftPadding - textPainter.width - 8, y - textPainter.height / 2),
      );

      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + chartWidth, y),
        axisPaint..strokeWidth = 0.5,
      );
    }

    if (xLabels.isNotEmpty) {
      final xLabelSteps = xLabels.length > 1 ? xLabels.length - 1 : 1;
      for (var i = 0; i < xLabels.length; i++) {
        final label = xLabels[i];
        final x = startX + (i * chartWidth / xLabelSteps);
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

class _IndiceClasse {
  final String label;
  final Color color;

  const _IndiceClasse(this.label, this.color);
}

class _FamiliaComparacaoBuilder {
  final int familiaId;
  final String familiaNome;
  final Map<int, _Aggregate> _categoriaAgg = {};
  final _Aggregate _mediaAgg = _Aggregate();
  final List<_AvaliacaoResumo> series = [];

  _FamiliaComparacaoBuilder({
    required this.familiaId,
    required this.familiaNome,
  });

  void addCategoria(int categoriaId, double valor) {
    _categoriaAgg.putIfAbsent(categoriaId, _Aggregate.new).add(valor);
  }

  void addMedia(DateTime date, double media) {
    _mediaAgg.add(media);
    series.add(_AvaliacaoResumo(date, media));
  }

  _FamiliaComparacao build(List<CategoriaData> categorias) {
    final orderedCategories = [...categorias]
      ..sort((a, b) => a.id.compareTo(b.id));

    final barras = <_IndiceBarData>[];
    for (final categoria in orderedCategories.take(4)) {
      final media = _categoriaAgg[categoria.id]?.average ?? 0.0;
      barras.add(_IndiceBarData(categoria.nome, media));
    }
    barras.add(_IndiceBarData('Média final', _mediaAgg.average));

    return _FamiliaComparacao(
      familiaId: familiaId,
      familiaNome: familiaNome,
      barras: barras,
      mediaFinal: _mediaAgg.average,
    );
  }
}

class _FamiliaComparacao {
  final int familiaId;
  final String familiaNome;
  final List<_IndiceBarData> barras;
  final double mediaFinal;

  _FamiliaComparacao({
    required this.familiaId,
    required this.familiaNome,
    required this.barras,
    required this.mediaFinal,
  });
}

class _IndiceBarData {
  final String label;
  final double valor;

  _IndiceBarData(this.label, this.valor);
}

class _EvolucaoFamilia {
  final int familiaId;
  final String familiaNome;
  final _AvaliacaoResumo inicio;
  final _AvaliacaoResumo fim;
  final double variacao;
  final int quantidadeAvaliacoes;

  _EvolucaoFamilia({
    required this.familiaId,
    required this.familiaNome,
    required this.inicio,
    required this.fim,
    required this.variacao,
    required this.quantidadeAvaliacoes,
  });
}

class _Aggregate {
  double total = 0.0;
  int count = 0;

  void add(double value) {
    total += value;
    count += 1;
  }

  double get average => count == 0 ? 0.0 : total / count;
}

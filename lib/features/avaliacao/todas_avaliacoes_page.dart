import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column, Table;

import '../../core/database/app_database.dart';
import '../../core/services/resultado_avaliacao_service.dart';
import '../../core/models/resultado_avaliacao.dart';
import 'resultados_avaliacao_page.dart';

class TodasAvaliacoesPage extends StatefulWidget {
  const TodasAvaliacoesPage({super.key});

  @override
  State<TodasAvaliacoesPage> createState() => _TodasAvaliacoesPageState();
}

class _TodasAvaliacoesPageState extends State<TodasAvaliacoesPage> {
  late AppDatabase _db;
  late ResultadoAvaliacaoService _resultadoService;
  bool _isLoading = true;
  List<_AvaliacaoComResultados> _avaliacoes = [];
  List<_AvaliacaoComResultados> _allAvaliacoes = [];
  List<FamiliaData> _familias = [];
  List<RegiaoData> _regioes = [];
  int? _selectedFamiliaFilter;
  int? _selectedRegiaoFilter;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

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
    final familiaNomes = {
      for (final familia in familias) familia.id: familia.nomeResponsavel,
    };
    final regiaoNomes = {
      for (final regiao in regioes) regiao.id: regiao.nome,
    };
    final familiaRegiaoIds = {
      for (final familia in familias) familia.id: familia.regiaoId,
    };

    final avaliacoes = await (_db.select(_db.avaliacao)
          ..orderBy([
            (a) => OrderingTerm(expression: a.data, mode: OrderingMode.desc)
          ]))
        .get();

    final avaliacoesComResultados = <_AvaliacaoComResultados>[];

    for (final avaliacao in avaliacoes) {
      final stats =
          await _resultadoService.obterEstatisticasAvaliacao(avaliacao.id);
      final familiaId = avaliacao.familiaId;
      final regiaoId = familiaRegiaoIds[familiaId];
      final regiaoNome = regiaoNomes[regiaoId] ??
          'Região ${regiaoId != null ? regiaoId : '—'}';

      avaliacoesComResultados.add(
        _AvaliacaoComResultados(
          item: avaliacao,
          familiaNome: familiaNomes[familiaId] ?? 'Família $familiaId',
          regiaoId: regiaoId,
          regiaoNome: regiaoNome,
          media: stats.isNotEmpty ? stats['media'] as double? : null,
          minValor: stats.isNotEmpty ? stats['minValor'] as double? : null,
          maxValor: stats.isNotEmpty ? stats['maxValor'] as double? : null,
          resultados: stats.isNotEmpty
              ? stats['resultados'] as List<ResultadoAvaliacao>?
              : null,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _familias = familias;
        _regioes = regioes;
        _allAvaliacoes = avaliacoesComResultados;
        _avaliacoes = _aplicarFiltros();
        _isLoading = false;
      });
    }
  }

  Color _obterCorPorValor(double? valor) {
    if (valor == null) return Colors.grey;
    if (valor >= 8.0) return Colors.green;
    if (valor >= 6.0) return Colors.blue;
    if (valor >= 4.0) return Colors.orange;
    if (valor >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  List<_AvaliacaoComResultados> _aplicarFiltros() {
    return _allAvaliacoes.where((item) {
      if (_selectedFamiliaFilter != null &&
          item.item.familiaId != _selectedFamiliaFilter) {
        return false;
      }
      if (_selectedRegiaoFilter != null &&
          item.regiaoId != _selectedRegiaoFilter) {
        return false;
      }
      if (_filterStartDate != null &&
          item.item.data.isBefore(_filterStartDate!)) {
        return false;
      }
      if (_filterEndDate != null && item.item.data.isAfter(_filterEndDate!)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _selecionarDataInicial() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _filterStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected == null) return;
    setState(() {
      _filterStartDate = selected;
      if (_filterEndDate != null && _filterEndDate!.isBefore(selected)) {
        _filterEndDate = selected;
      }
      _avaliacoes = _aplicarFiltros();
    });
  }

  Future<void> _selecionarDataFinal() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _filterEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected == null) return;
    setState(() {
      _filterEndDate = selected;
      if (_filterStartDate != null && _filterStartDate!.isAfter(selected)) {
        _filterStartDate = selected;
      }
      _avaliacoes = _aplicarFiltros();
    });
  }

  void _limparFiltros() {
    setState(() {
      _selectedFamiliaFilter = null;
      _selectedRegiaoFilter = null;
      _filterStartDate = null;
      _filterEndDate = null;
      _avaliacoes = _aplicarFiltros();
    });
  }

  Future<void> _editarAvaliacao(_AvaliacaoComResultados item) async {
    final avaliadorController =
        TextEditingController(text: item.item.avaliador);
    final observacoesController =
        TextEditingController(text: item.item.observacoes ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar avaliação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: avaliadorController,
                decoration: const InputDecoration(labelText: 'Avaliador'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: observacoesController,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    await (_db.update(_db.avaliacao)..where((a) => a.id.equals(item.item.id)))
        .write(
      AvaliacaoCompanion(
        avaliador: Value(avaliadorController.text),
        observacoes: Value(observacoesController.text.isEmpty
            ? null
            : observacoesController.text),
      ),
    );

    await _init();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação atualizada com sucesso.')),
    );
  }

  Future<void> _confirmarExcluirAvaliacao(_AvaliacaoComResultados item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir avaliação'),
          content: const Text(
              'Tem certeza que deseja excluir esta avaliação? Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _db.delete(_db.avaliacaoItem)
      ..where((ai) => ai.avaliacaoId.equals(item.item.id))
      ..go();

    await _db.delete(_db.avaliacao)
      ..where((a) => a.id.equals(item.item.id))
      ..go();

    await _init();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação excluída.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as Avaliações'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Filtros',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              DropdownButtonFormField<int>(
                                value: _selectedFamiliaFilter,
                                decoration: const InputDecoration(
                                  labelText: 'Família',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: null,
                                    child: Text('Todas as famílias'),
                                  ),
                                  ..._familias.map(
                                    (familia) => DropdownMenuItem<int>(
                                      value: familia.id,
                                      child: Text(familia.nomeResponsavel),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFamiliaFilter = value;
                                    _avaliacoes = _aplicarFiltros();
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<int>(
                                value: _selectedRegiaoFilter,
                                decoration: const InputDecoration(
                                  labelText: 'Região',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: null,
                                    child: Text('Todas as regiões'),
                                  ),
                                  ..._regioes.map(
                                    (regiao) => DropdownMenuItem<int>(
                                      value: regiao.id,
                                      child: Text(regiao.nome),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRegiaoFilter = value;
                                    _avaliacoes = _aplicarFiltros();
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selecionarDataInicial,
                                  icon: const Icon(Icons.calendar_month),
                                  label: Text(_filterStartDate == null
                                      ? 'Início'
                                      : _formatarData(_filterStartDate!)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selecionarDataFinal,
                                  icon: const Icon(Icons.calendar_today),
                                  label: Text(_filterEndDate == null
                                      ? 'Fim'
                                      : _formatarData(_filterEndDate!)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: _limparFiltros,
                                icon: const Icon(Icons.clear),
                                tooltip: 'Limpar filtros',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _avaliacoes.isEmpty
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
                                'Nenhuma avaliação registrada ainda',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _avaliacoes.length,
                          itemBuilder: (context, index) {
                            final item = _avaliacoes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: _obterCorPorValor(item.media)
                                      .withOpacity(0.16),
                                  child: Icon(
                                    Icons.checklist_rtl,
                                    color: _obterCorPorValor(item.media),
                                  ),
                                ),
                                title: Text(item.familiaNome),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_formatarData(item.item.data)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Avaliador: ${item.item.avaliador}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Região: ${item.regiaoNome}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: ${item.item.status}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (item.media != null)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            item.media!.toStringAsFixed(1),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  _obterCorPorValor(item.media),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Média',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _editarAvaliacao(item);
                                        } else if (value == 'delete') {
                                          _confirmarExcluirAvaliacao(item);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Editar'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Excluir'),
                                        ),
                                      ],
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: item.resultados != null
                                    ? () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ResultadosAvaliacaoPage(
                                              avaliacaoId: item.item.id,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}

class _AvaliacaoComResultados {
  final AvaliacaoData item;
  final String familiaNome;
  final int? regiaoId;
  final String regiaoNome;
  final double? media;
  final double? minValor;
  final double? maxValor;
  final List<ResultadoAvaliacao>? resultados;

  _AvaliacaoComResultados({
    required this.item,
    required this.familiaNome,
    required this.regiaoId,
    required this.regiaoNome,
    required this.media,
    required this.minValor,
    required this.maxValor,
    required this.resultados,
  });
}

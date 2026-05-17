// ==========================================
// CATEGORIA_FORM_PAGE.dart
// ==========================================

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/database/app_database.dart';
import '../../core/services/indicador_service.dart';

class CategoriaFormPage extends StatefulWidget {
  final int avaliacaoId;

  final int categoriaId;

  final int? familiaId;

  final int? categoriaAtual;

  final int? totalCategorias;

  const CategoriaFormPage({
    super.key,
    required this.avaliacaoId,
    required this.categoriaId,
    this.familiaId,
    this.categoriaAtual,
    this.totalCategorias,
  });

  @override
  State<CategoriaFormPage> createState() => _CategoriaFormPageState();
}

class _CategoriaFormPageState extends State<CategoriaFormPage> {
  late AppDatabase _db;

  late IndicadorService _indicadorService;

  CategoriaData? _categoria;

  List<IndicadorData> _indicadores = [];
  List<PraticaData> _praticas = [];

  bool _isLoading = true;

  bool _isSaving = false;

  final Map<int, int?> _respostas = {};
  // Para a categoria multidimensional (categoria 2) guardamos seleções
  // por prática: mapa praticaId -> conjunto de indicadorIds selecionados.
  final Map<int, Set<int>> _respostasPorPratica = {};

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();

    _indicadorService = IndicadorService(_db);

    final categoria = await _indicadorService.getCategoriaById(
      widget.categoriaId,
    );

    final indicadores = await _indicadorService.getIndicadoresByCategoria(
      widget.categoriaId,
    );

    // Se for a categoria multidimensional (segunda categoria do fluxo),
    // carregamos também as práticas vinculadas a essa categoria.
    if ((widget.categoriaAtual ?? 0) == 2) {
      _praticas = await (_db.select(_db.pratica)
            ..where((p) => p.categoriaId.equals(widget.categoriaId)))
          .get();
      for (final pratica in _praticas) {
        _respostasPorPratica[pratica.id] = <int>{};
      }
    }

    for (final indicador in indicadores) {
      _respostas[indicador.id] = null;
    }

    // Carregar valores já salvos para esta avaliação/indicadores
    final existingItems = await (_db.select(_db.avaliacaoItem)
          ..where((a) =>
              a.avaliacaoId.equals(widget.avaliacaoId) &
              a.indicadorId.isIn(indicadores.map((e) => e.id))))
        .get();

    for (final item in existingItems) {
      if (item.praticaId != null) {
        // categoria multidimensional: associe indicador à prática
        _respostasPorPratica[item.praticaId!] ??= <int>{};
        _respostasPorPratica[item.praticaId!]!.add(item.indicadorId);
      } else if (item.valorLikert != null) {
        _respostas[item.indicadorId] = item.valorLikert;
      }
    }

    setState(() {
      _categoria = categoria;

      _indicadores = indicadores;

      _isLoading = false;
    });
  }

  bool _todosPreenchidos() {
    // Para a categoria multidimensional, não exigimos que todos os
    // indicadores individuais (Likert) estejam preenchidos: o usuário deve
    // marcar as práticas observadas. Retornamos true direto.
    if ((widget.categoriaAtual ?? 0) == 2) return true;

    return _respostas.values.every((v) => v != null);
  }

  Future<void> _submit() async {
    if (!_todosPreenchidos()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os indicadores.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // remove respostas antigas (para os indicadores desta categoria)
      await (_db.delete(
        _db.avaliacaoItem,
      )..where(
              (a) =>
                  a.avaliacaoId.equals(widget.avaliacaoId) &
                  a.indicadorId.isIn(_indicadores.map((e) => e.id)),
            ))
          .go();

      if ((widget.categoriaAtual ?? 0) == 2) {
        // Salva seleções por prática: para cada prática, insere um item por
        // indicador marcado, vinculando `praticaId`.
        for (final entry in _respostasPorPratica.entries) {
          final praticaId = entry.key;
          for (final indicadorId in entry.value) {
            final item = AvaliacaoItemCompanion.insert(
              avaliacaoId: widget.avaliacaoId,
              indicadorId: indicadorId,
              praticaId: drift.Value(praticaId),
              valorLikert: const drift.Value(1),
            );

            await _db.into(_db.avaliacaoItem).insert(item);
          }
        }
      } else {
        // salva respostas Likert padrão
        for (final entry in _respostas.entries) {
          final valor = entry.value;

          if (valor == null) continue;

          final item = AvaliacaoItemCompanion.insert(
            avaliacaoId: widget.avaliacaoId,
            indicadorId: entry.key,
            valorLikert: drift.Value(valor),
          );

          await _db.into(_db.avaliacaoItem).insert(item);
        }
      }

      // Atualiza apenas a data de alteração — não mantemos mais o campo
      // `categoriaAtual` no fluxo da aplicação.
      await (_db.update(
        _db.avaliacao,
      )..where((a) => a.id.equals(widget.avaliacaoId)))
          .write(AvaliacaoCompanion(
        dataAlteracao: drift.Value(DateTime.now()),
      ));

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (widget.categoriaAtual ?? 1) / (widget.totalCategorias ?? 1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _categoria?.nome ?? 'Avaliação',
            ),
            Text(
              'Categoria ${widget.categoriaAtual} de ${widget.totalCategorias}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: LinearProgressIndicator(
              value: progress,
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Text(
                    'Continuar',
                  ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ((widget.categoriaAtual ?? 0) == 2
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                  width: 220,
                                  child: Text('Práticas agrícolas')),
                              ..._indicadores.map(
                                (ind) => Container(
                                  width: 140,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    ind.nome,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Rows
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: _praticas.map((pratica) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 220,
                                      child: Text(pratica.nome),
                                    ),
                                    ..._indicadores.map((ind) {
                                      final selected =
                                          _respostasPorPratica[pratica.id]
                                                  ?.contains(ind.id) ??
                                              false;
                                      return Container(
                                        width: 140,
                                        alignment: Alignment.center,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              final set = _respostasPorPratica[
                                                  pratica.id]!;
                                              if (selected) {
                                                set.remove(ind.id);
                                              } else {
                                                set.add(ind.id);
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: selected ? 36 : 32,
                                            height: selected ? 36 : 32,
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: selected
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: Center(
                                              child: selected
                                                  ? const Icon(Icons.check,
                                                      color: Colors.white,
                                                      size: 18)
                                                  : const SizedBox.shrink(),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    ..._indicadores.map(
                      _buildIndicador,
                    ),
                  ],
                )),
    );
  }

  Widget _buildIndicador(IndicadorData indicador) {
    final valor = _respostas[indicador.id];

    return Container(
      margin: const EdgeInsets.only(
        bottom: 24,
      ),
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            indicador.nome,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            indicador.descricao,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
              (index) {
                final number = index + 1;

                final selected = valor == number;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _respostas[indicador.id] = number;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 150,
                    ),
                    width: selected ? 50 : 42,
                    height: selected ? 50 : 42,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(
                        14,
                      ),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$number',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

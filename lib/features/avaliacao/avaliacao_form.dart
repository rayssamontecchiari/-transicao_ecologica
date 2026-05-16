// ==========================================
// CATEGORIA_FORM_PAGE.dart
// ==========================================

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/database/app_database.dart';
import '../../core/services/indicadores_service.dart';

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

  late IndicadoresService _indicadoresService;

  Categoria? _categoria;

  List<Indicador> _indicadores = [];

  bool _isLoading = true;

  bool _isSaving = false;

  final Map<int, int?> _respostas = {};

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();

    _indicadoresService = IndicadoresService(_db);

    final categoria = await _indicadoresService.getCategoriaById(
      widget.categoriaId,
    );

    final indicadores = await _indicadoresService.getIndicadoresByCategoria(
      widget.categoriaId,
    );

    for (final indicador in indicadores) {
      _respostas[indicador.id] = null;
    }

    setState(() {
      _categoria = categoria;

      _indicadores = indicadores;

      _isLoading = false;
    });
  }

  bool _todosPreenchidos() {
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
      // remove respostas antigas
      await (_db.delete(
        _db.avaliacaoItens,
      )..where(
              (a) =>
                  a.avaliacaoId.equals(
                    widget.avaliacaoId,
                  ) &
                  a.indicadorId.isIn(
                    _indicadores.map((e) => e.id),
                  ),
            ))
          .go();

      // salva respostas
      for (final entry in _respostas.entries) {
        final valor = entry.value;

        if (valor == null) continue;

        final item = AvaliacaoItensCompanion.insert(
          avaliacaoId: widget.avaliacaoId,
          indicadorId: entry.key,
          valorLikert: drift.Value(valor),
        );

        await _db.into(_db.avaliacaoItens).insert(item);
      }

      // atualiza progresso
      await (_db.update(
        _db.avaliacoes,
      )..where(
              (a) => a.id.equals(
                widget.avaliacaoId,
              ),
            ))
          .write(
        AvaliacoesCompanion(
          categoriaAtual: drift.Value(
            widget.categoriaAtual ?? 0,
          ),
          dataAlteracao: drift.Value(
            DateTime.now(),
          ),
        ),
      );

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
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ..._indicadores.map(
                  _buildIndicador,
                ),
              ],
            ),
    );
  }

  Widget _buildIndicador(Indicador indicador) {
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

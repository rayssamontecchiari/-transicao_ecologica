import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column, Table;

import '../../core/database/app_database.dart';

/// Página para administrar/ajustar os pesos dos indicadores por categoria
class GerenciarPesosPage extends StatefulWidget {
  final int? categoriaIdInicial;

  const GerenciarPesosPage({
    super.key,
    this.categoriaIdInicial,
  });

  @override
  State<GerenciarPesosPage> createState() => _GerenciarPesosPageState();
}

class _GerenciarPesosPageState extends State<GerenciarPesosPage> {
  late AppDatabase _db;

  bool _isLoading = true;
  int? _categoriaSelecionada;
  List<Categoria> _categorias = [];
  List<_IndicadorComPeso> _indicadores = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();

    final categorias = await _db.select(_db.categorias).get();

    setState(() {
      _categorias = categorias;
      _categoriaSelecionada = widget.categoriaIdInicial ??
          (categorias.isNotEmpty ? categorias[0].id : null);
      _isLoading = false;
    });

    if (_categoriaSelecionada != null) {
      await _carregarIndicadores(_categoriaSelecionada!);
    }
  }

  Future<void> _carregarIndicadores(int categoriaId) async {
    final indicadores = await (_db.select(_db.indicadores)
          ..where((i) => i.categoriaId.equals(categoriaId))
          ..orderBy(
              [(i) => OrderingTerm(expression: i.id, mode: OrderingMode.asc)]))
        .get();

    setState(() {
      _indicadores = indicadores
          .map((i) => _IndicadorComPeso(
                indicador: i,
                pesoController: TextEditingController(text: i.peso.toString()),
              ))
          .toList();
    });
  }

  Future<void> _salvarPesos() async {
    try {
      // Validar e atualizar todos os pesos
      for (final item in _indicadores) {
        final novoPeso = double.tryParse(item.pesoController.text);

        if (novoPeso == null || novoPeso < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Peso inválido para ${item.indicador.nome}. Use um número positivo.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Atualizar no banco
        await _db.update(_db.indicadores).replace(
              IndicadoresCompanion(
                id: Value(item.indicador.id),
                nome: Value(item.indicador.nome),
                descricao: Value(item.indicador.descricao),
                peso: Value(novoPeso),
                categoriaId: Value(item.indicador.categoriaId),
                dimensaoId: Value(item.indicador.dimensaoId),
              ),
            );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesos atualizados com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Recarregar
      if (_categoriaSelecionada != null) {
        await _carregarIndicadores(_categoriaSelecionada!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar pesos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Pesos dos Indicadores'),
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
                    // Selector de categoria
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Categoria',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<int>(
                              isExpanded: true,
                              value: _categoriaSelecionada,
                              onChanged: (int? novaCategoria) async {
                                if (novaCategoria != null) {
                                  setState(
                                    () => _categoriaSelecionada = novaCategoria,
                                  );
                                  await _carregarIndicadores(novaCategoria);
                                }
                              },
                              items: _categorias
                                  .map<DropdownMenuItem<int>>(
                                    (categoria) => DropdownMenuItem<int>(
                                      value: categoria.id,
                                      child: Text(categoria.nome),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lista de indicadores com pesos
                    if (_indicadores.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Indicadores (${_indicadores.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _indicadores.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = _indicadores[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.indicador.nome,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (item.indicador.descricao.isNotEmpty)
                                        Text(
                                          item.indicador.descricao,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      const SizedBox(height: 12),
                                      // Input para peso
                                      TextField(
                                        controller: item.pesoController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Peso',
                                          hintText: '0.0 - 1.0',
                                          suffixText:
                                              '(atual: ${item.indicador.peso})',
                                          border: const OutlineInputBorder(),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Nenhum indicador encontrado para esta categoria',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Botão salvar
                    if (_indicadores.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: _salvarPesos,
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar Pesos'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    for (final item in _indicadores) {
      item.pesoController.dispose();
    }
    super.dispose();
  }
}

class _IndicadorComPeso {
  final Indicador indicador;
  final TextEditingController pesoController;

  _IndicadorComPeso({
    required this.indicador,
    required this.pesoController,
  });
}

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/categoria_service.dart';
import '../../core/services/indicador_service.dart';
import 'gerenciar_pesos_page.dart';
import 'indicador_form.dart';

class IndicadoresPage extends StatefulWidget {
  const IndicadoresPage({super.key});

  @override
  State<IndicadoresPage> createState() => _IndicadoresPageState();
}

class _IndicadoresPageState extends State<IndicadoresPage>
    with SingleTickerProviderStateMixin {
  late AppDatabase _db;
  late CategoriaService _categoriaService;
  late IndicadorService _indicadorService;
  late TabController _tabController;

  bool _isLoading = true;
  List<CategoriaData> _categorias = [];
  List<IndicadorData> _indicadores = [];
  int? _filtroCategoriaId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _categoriaService = CategoriaService(_db);
    _indicadorService = IndicadorService(_db);
    await _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    final categorias = await _categoriaService.getTodas();
    final indicadores = await _db.select(_db.indicador).get();

    if (!mounted) return;
    setState(() {
      _categorias = categorias;
      _indicadores = indicadores;
      _filtroCategoriaId ??= categorias.isNotEmpty ? categorias.first.id : null;
      _isLoading = false;
    });
  }

  Future<void> _abrirFormularioCategoria({CategoriaData? categoria}) async {
    final nomeController = TextEditingController(text: categoria?.nome ?? '');
    final descricaoController =
        TextEditingController(text: categoria?.descricao ?? '');

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(categoria == null ? 'Nova Categoria' : 'Editar Categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              minLines: 2,
              maxLines: 4,
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
      ),
    );

    if (confirmou != true) return;

    final nome = nomeController.text.trim();
    final descricao = descricaoController.text.trim();
    if (nome.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome da categoria é obrigatório.')),
      );
      return;
    }

    try {
      final companion = CategoriaCompanion(
        nome: Value(nome),
        descricao: Value(descricao.isEmpty ? null : descricao),
      );

      if (categoria == null) {
        await _categoriaService.inserir(companion);
      } else {
        await _categoriaService.atualizarCategoria(categoria.id, companion);
      }

      await _carregarDados();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            categoria == null
                ? 'Categoria cadastrada com sucesso.'
                : 'Categoria atualizada com sucesso.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar categoria: $e')),
      );
    }
  }

  Future<void> _excluirCategoria(CategoriaData categoria) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text(
          'Deseja excluir a categoria "${categoria.nome}"? A exclusão só é permitida se não houver vínculos.',
        ),
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
      ),
    );

    if (confirmou != true) return;

    try {
      await _categoriaService.deletarCategoria(categoria.id);
      await _carregarDados();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoria excluída com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exclusão não permitida: $e')),
      );
    }
  }

  Future<void> _abrirFormularioIndicador({IndicadorData? indicador}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => IndicadorFormPage(
          indicador: indicador,
          categoriaIdInicial: _filtroCategoriaId,
        ),
      ),
    );

    if (result == true) {
      await _carregarDados();
    }
  }

  Future<void> _excluirIndicador(IndicadorData indicador) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir indicador'),
        content: Text(
          'Deseja excluir o indicador "${indicador.nome}"? Indicadores usados em avaliações não podem ser removidos.',
        ),
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
      ),
    );

    if (confirmou != true) return;

    try {
      await _indicadorService.deletarIndicador(indicador.id);
      await _carregarDados();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indicador excluído com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exclusão não permitida: $e')),
      );
    }
  }

  List<IndicadorData> _indicadoresFiltrados() {
    if (_filtroCategoriaId == null) return _indicadores;
    return _indicadores
        .where((indicador) => indicador.categoriaId == _filtroCategoriaId)
        .toList();
  }

  String _nomeCategoria(int categoriaId) {
    return _categorias
            .where((categoria) => categoria.id == categoriaId)
            .cast<CategoriaData?>()
            .firstOrNull
            ?.nome ??
        'Categoria $categoriaId';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias e Indicadores'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categorias'),
            Tab(text: 'Indicadores'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Gerenciar pesos',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GerenciarPesosPage(
                    categoriaIdInicial: _filtroCategoriaId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriasTab(),
                _buildIndicadoresTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _abrirFormularioCategoria();
          } else {
            _abrirFormularioIndicador();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(
            _tabController.index == 0 ? 'Nova categoria' : 'Novo indicador'),
      ),
    );
  }

  Widget _buildCategoriasTab() {
    if (_categorias.isEmpty) {
      return const Center(
        child: Text('Nenhuma categoria cadastrada.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _categorias.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
          final totalIndicadores = _indicadores
              .where((indicador) => indicador.categoriaId == categoria.id)
              .length;

          return Card(
            child: ListTile(
              title: Text(categoria.nome),
              subtitle: Text(
                '${categoria.descricao ?? 'Sem descrição'}\nIndicadores: $totalIndicadores',
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar categoria',
                    onPressed: () =>
                        _abrirFormularioCategoria(categoria: categoria),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Excluir categoria',
                    onPressed: () => _excluirCategoria(categoria),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicadoresTab() {
    final indicadores = _indicadoresFiltrados();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: DropdownButtonFormField<int?>(
            value: _filtroCategoriaId,
            decoration: const InputDecoration(
              labelText: 'Filtrar por categoria',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Todas as categorias'),
              ),
              ..._categorias.map(
                (categoria) => DropdownMenuItem<int?>(
                  value: categoria.id,
                  child: Text(categoria.nome),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() => _filtroCategoriaId = value);
            },
          ),
        ),
        Expanded(
          child: indicadores.isEmpty
              ? const Center(child: Text('Nenhum indicador encontrado.'))
              : RefreshIndicator(
                  onRefresh: _carregarDados,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: indicadores.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final indicador = indicadores[index];
                      return Card(
                        child: ListTile(
                          title: Text(indicador.nome),
                          subtitle: Text(
                            '${_nomeCategoria(indicador.categoriaId)}\nPeso: ${indicador.peso.toStringAsFixed(2)}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Editar indicador',
                                onPressed: () => _abrirFormularioIndicador(
                                    indicador: indicador),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Excluir indicador',
                                onPressed: () => _excluirIndicador(indicador),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

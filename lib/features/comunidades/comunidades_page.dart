import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/comunidade_service.dart';
import 'cadastro_comunidade_page.dart';

class GerenciarComunidadesPage extends StatefulWidget {
  const GerenciarComunidadesPage({super.key});

  @override
  State<GerenciarComunidadesPage> createState() =>
      _GerenciarComunidadesPageState();
}

class _GerenciarComunidadesPageState extends State<GerenciarComunidadesPage> {
  late AppDatabase _db;
  late ComunidadeService _comunidadeService;

  List<ComunidadeData> _comunidades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _comunidadeService = ComunidadeService(_db);
    await _carregarComunidades();
  }

  Future<void> _carregarComunidades() async {
    setState(() => _isLoading = true);

    try {
      final comunidades = await _comunidadeService.getTodas();
      if (mounted) {
        setState(() {
          _comunidades = comunidades;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar comunidades: $e')),
        );
      }
    }
  }

  Future<void> _abrirFormulario({ComunidadeData? comunidade}) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CadastroComunidadePage(comunidade: comunidade),
      ),
    );

    if (resultado == true) {
      await _carregarComunidades();
    }
  }

  Future<void> _excluirComunidade(ComunidadeData comunidade) async {
    final quantidadeFamilias =
        await _comunidadeService.contarFamiliasVinculadas(comunidade.id);

    if (quantidadeFamilias > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não é possível excluir uma comunidade com famílias vinculadas.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Deseja realmente excluir a comunidade "${comunidade.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _comunidadeService.deletarComunidade(comunidade.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Comunidade "${comunidade.nome}" excluída com sucesso.'),
          ),
        );
      }
      await _carregarComunidades();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir comunidade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Comunidades'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nova comunidade'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _comunidades.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group_off,
                            size: 52, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma comunidade cadastrada.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crie uma nova comunidade para começar a organizar famílias.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _comunidades.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final comunidade = _comunidades[index];
                    final possuiFamilias = false;

                    return FutureBuilder<int>(
                      future: _comunidadeService
                          .contarFamiliasVinculadas(comunidade.id),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        final bloqueado = count > 0;

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Text(
                                comunidade.nome.isNotEmpty
                                    ? comunidade.nome
                                        .substring(0, 1)
                                        .toUpperCase()
                                    : 'C',
                              ),
                            ),
                            title: Text(comunidade.nome),
                            subtitle: Text(
                              bloqueado
                                  ? '$count família(s) vinculada(s)'
                                  : 'Sem famílias vinculadas',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar comunidade',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () =>
                                      _abrirFormulario(comunidade: comunidade),
                                ),
                                IconButton(
                                  tooltip: bloqueado
                                      ? 'Exclusão bloqueada'
                                      : 'Excluir comunidade',
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: bloqueado ? Colors.grey : Colors.red,
                                  ),
                                  onPressed: bloqueado
                                      ? null
                                      : () => _excluirComunidade(comunidade),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

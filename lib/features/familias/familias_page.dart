import 'package:flutter/material.dart';
import 'package:transicao_ecologica/features/familias/familia_details.dart';
import '../../core/database/app_database.dart';
import '../../core/services/familia_service.dart';
import 'cadastro_familia_page.dart';

class FamiliasListPage extends StatefulWidget {
  const FamiliasListPage({super.key});

  @override
  State<FamiliasListPage> createState() => _FamiliasListPageState();
}

class _FamiliasListPageState extends State<FamiliasListPage> {
  late AppDatabase _db;
  late FamiliasService _familiasService;

  List<FamiliaData> _familias = [];
  List<FamiliaData> _familiasFiltradas = [];
  List<RegiaoData> _regioes = [];
  int? _selectedRegiaoFilter;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _familiasService = FamiliasService(_db);
    _regioes = await _db.select(_db.regiao).get();
    await _carregarFamilias();
  }

  void _aplicarFiltros() {
    final query = _searchQuery.toLowerCase().trim();
    _familiasFiltradas = _familias.where((familia) {
      if (_selectedRegiaoFilter != null &&
          familia.regiaoId != _selectedRegiaoFilter) {
        return false;
      }
      if (query.isNotEmpty &&
          !familia.nomeResponsavel.toLowerCase().contains(query) &&
          !familia.endereco.toLowerCase().contains(query) &&
          !familia.telefone.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _carregarFamilias() async {
    setState(() => _isLoading = true);

    try {
      final familias = await _familiasService.getTodas();

      if (mounted) {
        setState(() {
          _familias = familias;
          _aplicarFiltros();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar famílias: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletarFamilia(int id) async {
    try {
      await _familiasService.deletarFamilia(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Família deletada com sucesso!'),
            duration: Duration(seconds: 2),
          ),
        );

        await _carregarFamilias();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar família: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmarDelecao(FamiliaData familia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Deleção'),
        content: Text(
          'Deseja realmente deletar a família "${familia.nomeResponsavel}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletarFamilia(familia.id);
            },
            child: const Text(
              'Deletar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editarFamilia(FamiliaData familia) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CadastroFamiliaPage(familia: familia),
      ),
    );
    _carregarFamilias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Famílias Cadastradas'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CadastroFamiliaPage(),
            ),
          );
          _carregarFamilias();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
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
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Buscar família',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                _aplicarFiltros();
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
                                _aplicarFiltros();
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedRegiaoFilter = null;
                                _searchQuery = '';
                                _aplicarFiltros();
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Limpar filtros'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _familiasFiltradas.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhuma família encontrada',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _carregarFamilias,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _familiasFiltradas.length,
                            itemBuilder: (context, index) {
                              final familia = _familiasFiltradas[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  child: ListTile(
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => FamiliaDetalhesPage(
                                            familiaId: familia.id,
                                          ),
                                        ),
                                      );

                                      // Opcional: recarrega a lista ao voltar
                                      _carregarFamilias();
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
                                      child: Text(
                                        familia.id.toString(),
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      familia.nomeResponsavel,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'ID: ${familia.id}',
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _editarFamilia(familia);
                                        } else if (value == 'delete') {
                                          _confirmarDelecao(familia);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit,
                                                  color: Colors.blue, size: 20),
                                              SizedBox(width: 8),
                                              Text('Editar'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'Deletar',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

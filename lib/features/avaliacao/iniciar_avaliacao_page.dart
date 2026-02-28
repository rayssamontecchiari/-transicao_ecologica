import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/familia_service.dart';
import '../../core/services/categorias_service.dart';
import 'avaliacao_form.dart';

/// Página inicial do fluxo de avaliação.
/// Permite selecionar uma família e iniciar o fluxo de 4 categorias de avaliação.
class IniciarAvaliacaoPage extends StatefulWidget {
  const IniciarAvaliacaoPage({super.key});

  @override
  State<IniciarAvaliacaoPage> createState() => _IniciarAvaliacaoPageState();
}

class _IniciarAvaliacaoPageState extends State<IniciarAvaliacaoPage> {
  late FamiliasService _familiasService;
  late CategoriasService _categoriasService;
  late AppDatabase _db;

  List<Familia> _familias = [];
  List<Categoria> _categorias = [];
  Familia? _selectedFamilia;
  bool _isLoading = true;
  int _categoriaAtual = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _familiasService = FamiliasService(_db);
    _categoriasService = CategoriasService(_db);

    final familias = await _familiasService.getTodas();
    final categorias = await _categoriasService.getTodas();

    setState(() {
      _familias = familias;
      _categorias = categorias;
      _isLoading = false;
      if (familias.isNotEmpty) {
        _selectedFamilia = familias.first;
      }
    });
  }

  Future<void> _iniciarAvaliacao() async {
    if (_selectedFamilia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma família')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      for (int i = 0; i < _categorias.length; i++) {
        if (!mounted) break;

        setState(() => _categoriaAtual = i);

        final categoria = _categorias[i];

        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => CategoriaFormPage(categoriaId: categoria.id),
            settings: RouteSettings(
              arguments: {
                'familiaId': _selectedFamilia!.id,
                'categoriaAtual': i + 1,
                'totalCategorias': _categorias.length,
              },
            ),
          ),
        );

        if (result != true) {
          // User cancelled
          break;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Avaliação completa!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Avaliação'),
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
                    // Cabeçalho informativo
                    Card(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Como funciona',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Você fará uma avaliação em 4 categorias. '
                                        'Para cada categoria, preencha os indicadores conforme necessário.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Seleção de família
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Passo 1: Selecione a Família',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),

                    DropdownButtonFormField<Familia>(
                      value: _selectedFamilia,
                      decoration: const InputDecoration(
                        labelText: 'Família *',
                        hintText: 'Escolha uma família',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
                      ),
                      items: _familias
                          .map((f) => DropdownMenuItem(
                                value: f,
                                child: Text(
                                  '${f.nomeResponsavel} (Família #${f.id})',
                                ),
                              ))
                          .toList(),
                      onChanged: _isProcessing
                          ? null
                          : (f) => setState(() => _selectedFamilia = f),
                    ),

                    const SizedBox(height: 32),

                    // Categorias a serem avaliadas
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Passo 2: Preencha as 4 Categorias',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _categorias.length,
                      itemBuilder: (context, index) {
                        final categoria = _categorias[index];
                        final isCompleted = index < _categoriaAtual;
                        final isCurrent = index == _categoriaAtual;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            color: isCompleted
                                ? Colors.green.withOpacity(0.1)
                                : isCurrent
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.05)
                                    : null,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCompleted
                                          ? Colors.green
                                          : isCurrent
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[300],
                                    ),
                                    child: Center(
                                      child: Text(
                                        isCompleted ? '✓' : '${index + 1}',
                                        style: TextStyle(
                                          color: isCompleted || isCurrent
                                              ? Colors.white
                                              : Colors.grey[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          categoria.nome,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (categoria.descricao != null &&
                                            categoria.descricao!.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              categoria.descricao!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isCompleted)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Botão de ação
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _iniciarAvaliacao,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(
                          _isProcessing
                              ? 'Processando Avaliação...'
                              : 'Iniciar Avaliação',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botão de cancelamento
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed:
                            _isProcessing ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

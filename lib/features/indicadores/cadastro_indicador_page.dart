import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/indicadores_service.dart';
import '../../core/services/categorias_service.dart';

/// Página para cadastro de indicadores.
class CadastroIndicadorPage extends StatefulWidget {
  const CadastroIndicadorPage({super.key});

  @override
  State<CadastroIndicadorPage> createState() => _CadastroIndicadorPageState();
}

class _CadastroIndicadorPageState extends State<CadastroIndicadorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _pesoController = TextEditingController(text: '1.0');

  late IndicadoresService _indicadoresService;
  late CategoriasService _categoriasService;

  List<Categoria> _categorias = [];
  Categoria? _selectedCategoria;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = await AppDatabase.instance();
    _indicadoresService = IndicadoresService(db);
    _categoriasService = CategoriasService(db);
    await _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    try {
      final cats = await _categoriasService.getTodas();
      setState(() {
        _categorias = cats;
        _isLoading = false;
        if (cats.isNotEmpty) {
          _selectedCategoria = cats.first;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar categorias: $e')));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione uma categoria')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final peso = double.tryParse(_pesoController.text) ?? 1.0;
      final indicador = IndicadoresCompanion(
        nome: Value(_nomeController.text),
        descricao: Value(_descricaoController.text),
        peso: Value(peso),
        categoriaId: Value(_selectedCategoria!.id),
      );
      await _indicadoresService.inserirIndicador(indicador);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Indicador cadastrado com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar indicador: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Indicador')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Nome é obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pesoController,
                      decoration: const InputDecoration(
                        labelText: 'Peso',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Peso é obrigatório';
                        if (double.tryParse(v) == null) return 'Peso inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Categoria>(
                      value: _selectedCategoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                      ),
                      items: _categorias
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.nome),
                              ))
                          .toList(),
                      onChanged: (c) => setState(() => _selectedCategoria = c),
                      validator: (v) =>
                          v == null ? 'Categoria obrigatória' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Cadastrar Indicador'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

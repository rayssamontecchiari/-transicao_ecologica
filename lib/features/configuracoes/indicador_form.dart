import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/indicador_service.dart';

class IndicadorFormPage extends StatefulWidget {
  final IndicadorData? indicador;
  final int? categoriaIdInicial;

  const IndicadorFormPage({
    super.key,
    this.indicador,
    this.categoriaIdInicial,
  });

  @override
  State<IndicadorFormPage> createState() => _IndicadorFormPageState();
}

class _IndicadorFormPageState extends State<IndicadorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _nivel1Controller = TextEditingController();
  final _nivel5Controller = TextEditingController();
  final _pesoController = TextEditingController(text: '1.0');

  late AppDatabase _db;
  late IndicadorService _indicadorService;

  bool _isLoading = true;
  bool _isSaving = false;

  List<CategoriaData> _categorias = [];
  List<DimensaoData> _dimensoes = [];
  CategoriaData? _categoriaSelecionada;
  DimensaoData? _dimensaoSelecionada;

  bool get _isEditing => widget.indicador != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _indicadorService = IndicadorService(_db);

    final categorias = await _db.select(_db.categoria).get();

    CategoriaData? categoriaSelecionada;
    if (_isEditing) {
      categoriaSelecionada = categorias
          .where((c) => c.id == widget.indicador!.categoriaId)
          .cast<CategoriaData?>()
          .firstOrNull;
    } else if (widget.categoriaIdInicial != null) {
      categoriaSelecionada = categorias
          .where((c) => c.id == widget.categoriaIdInicial)
          .cast<CategoriaData?>()
          .firstOrNull;
    }
    categoriaSelecionada ??= categorias.isNotEmpty ? categorias.first : null;

    if (_isEditing) {
      _nomeController.text = widget.indicador!.nome;
      _descricaoController.text = widget.indicador!.descricao;
      _nivel1Controller.text = widget.indicador!.descricaoNivel1 ?? '';
      _nivel5Controller.text = widget.indicador!.descricaoNivel5 ?? '';
      _pesoController.text = widget.indicador!.peso.toString();
    }

    setState(() {
      _categorias = categorias;
      _categoriaSelecionada = categoriaSelecionada;
      _isLoading = false;
    });

    if (_categoriaSelecionada != null) {
      await _carregarDimensoes(_categoriaSelecionada!.id);
    }
  }

  Future<void> _carregarDimensoes(int categoriaId) async {
    final dimensoes = await (_db.select(_db.dimensao)
          ..where((d) => d.categoriaId.equals(categoriaId)))
        .get();

    DimensaoData? dimensaoSelecionada;
    if (_isEditing && widget.indicador!.dimensaoId != null) {
      dimensaoSelecionada = dimensoes
          .where((d) => d.id == widget.indicador!.dimensaoId)
          .cast<DimensaoData?>()
          .firstOrNull;
    }

    if (!mounted) return;
    setState(() {
      _dimensoes = dimensoes;
      _dimensaoSelecionada = dimensaoSelecionada;
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria.')),
      );
      return;
    }

    final peso = double.tryParse(_pesoController.text.trim());
    if (peso == null || peso < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um peso numérico válido.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final companion = IndicadorCompanion(
        nome: Value(_nomeController.text.trim()),
        descricao: Value(_descricaoController.text.trim()),
        descricaoNivel1: Value(
          _nivel1Controller.text.trim().isEmpty
              ? null
              : _nivel1Controller.text.trim(),
        ),
        descricaoNivel5: Value(
          _nivel5Controller.text.trim().isEmpty
              ? null
              : _nivel5Controller.text.trim(),
        ),
        peso: Value(peso),
        categoriaId: Value(_categoriaSelecionada!.id),
        dimensaoId: Value(_dimensaoSelecionada?.id),
      );

      if (_isEditing) {
        await _indicadorService.atualizarIndicador(
            widget.indicador!.id, companion);
      } else {
        await _indicadorService.inserirIndicador(companion);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar indicador: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _nivel1Controller.dispose();
    _nivel5Controller.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Indicador' : 'Novo Indicador'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Descrição é obrigatória';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nivel1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Significado da nota 1 (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nivel5Controller,
                    decoration: const InputDecoration(
                      labelText: 'Significado da nota 5 (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pesoController,
                    decoration: const InputDecoration(
                      labelText: 'Peso',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final parsed = double.tryParse(value?.trim() ?? '');
                      if (parsed == null || parsed < 0) {
                        return 'Informe um peso válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CategoriaData>(
                    value: _categoriaSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: _categorias
                        .map(
                          (categoria) => DropdownMenuItem<CategoriaData>(
                            value: categoria,
                            child: Text(categoria.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      setState(() {
                        _categoriaSelecionada = value;
                        _dimensaoSelecionada = null;
                      });
                      if (value != null) {
                        await _carregarDimensoes(value.id);
                      }
                    },
                    validator: (value) {
                      if (value == null) return 'Categoria é obrigatória';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DimensaoData?>(
                    value: _dimensaoSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Dimensão (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<DimensaoData?>(
                        value: null,
                        child: Text('Sem dimensão'),
                      ),
                      ..._dimensoes.map(
                        (dimensao) => DropdownMenuItem<DimensaoData?>(
                          value: dimensao,
                          child: Text(dimensao.nome),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _dimensaoSelecionada = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _salvar,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_isEditing
                        ? 'Salvar Alterações'
                        : 'Cadastrar Indicador'),
                  ),
                ],
              ),
            ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

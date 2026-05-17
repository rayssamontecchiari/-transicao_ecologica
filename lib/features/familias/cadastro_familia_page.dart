import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/familia_service.dart';
import '../../core/services/regiao_service.dart';

/// Página para cadastro de novas famílias.
class CadastroFamiliaPage extends StatefulWidget {
  final FamiliaData? familia;

  const CadastroFamiliaPage({super.key, this.familia});

  @override
  State<CadastroFamiliaPage> createState() => _CadastroFamiliaPageState();
}

class _CadastroFamiliaPageState extends State<CadastroFamiliaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeResponsavelController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();

  late FamiliasService _familiasService;
  late RegiaoService _regioesService;

  List<RegiaoData> _regioes = [];
  RegiaoData? _selectedRegiao;
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.familia != null;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final db = await AppDatabase.instance();
    _familiasService = FamiliasService(db);
    _regioesService = RegiaoService(db);
    await _loadRegioes();

    // Se estiver editando, preencher os campos
    if (_isEditing) {
      _nomeResponsavelController.text = widget.familia!.nomeResponsavel;
      _telefoneController.text = widget.familia!.telefone ?? '';
      _enderecoController.text = widget.familia!.endereco ?? '';
    }
  }

  Future<void> _loadRegioes() async {
    try {
      final regioes = await _regioesService.getTodas();
      setState(() {
        _regioes = regioes;
        _isLoading = false;
        if (_regioes.isNotEmpty) {
          if (_isEditing) {
            _selectedRegiao = _regioes.firstWhere(
              (r) => r.id == widget.familia!.regiaoId,
              orElse: () => _regioes.first,
            );
          } else {
            _selectedRegiao = _regioes.first;
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar regiões: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegiao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma região')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final familia = FamiliaCompanion(
        nomeResponsavel: Value(_nomeResponsavelController.text),
        telefone: Value(_telefoneController.text),
        endereco: Value(_enderecoController.text),
        regiaoId: Value(_selectedRegiao!.id),
      );

      if (_isEditing) {
        await _familiasService.atualizarFamilia(widget.familia!.id, familia);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Família atualizada com sucesso!')),
          );
        }
      } else {
        await _familiasService.cadastrarFamilia(familia);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Família cadastrada com sucesso!')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao ${_isEditing ? 'atualizar' : 'cadastrar'} família: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nomeResponsavelController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Família' : 'Cadastro de Família'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeResponsavelController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Responsável',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nome é obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Telefone é obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _enderecoController,
                      decoration: const InputDecoration(
                        labelText: 'Endereço',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Endereço é obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RegiaoData>(
                      value: _selectedRegiao,
                      decoration: const InputDecoration(
                        labelText: 'Região',
                        border: OutlineInputBorder(),
                      ),
                      items: _regioes
                          .map((regiao) => DropdownMenuItem(
                                value: regiao,
                                child: Text(regiao.nome),
                              ))
                          .toList(),
                      onChanged: (regiao) {
                        setState(() => _selectedRegiao = regiao);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Região é obrigatória';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submitForm,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_isEditing
                                ? 'Atualizar Família'
                                : 'Cadastrar Família'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

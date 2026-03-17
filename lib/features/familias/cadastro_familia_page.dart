import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/familia_service.dart';
import '../../core/services/regioes_service.dart';

/// Página para cadastro de novas famílias.
class CadastroFamiliaPage extends StatefulWidget {
  const CadastroFamiliaPage({super.key});

  @override
  State<CadastroFamiliaPage> createState() => _CadastroFamiliaPageState();
}

class _CadastroFamiliaPageState extends State<CadastroFamiliaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeResponsavelController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();

  late FamiliasService _familiasService;
  late RegioesService _regioesService;

  List<Regiao> _regioes = [];
  Regiao? _selectedRegiao;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final db = await AppDatabase.instance();
    _familiasService = FamiliasService(db);
    _regioesService = RegioesService(db);
    await _loadRegioes();
  }

  Future<void> _loadRegioes() async {
    try {
      final regioes = await _regioesService.getTodas();
      setState(() {
        _regioes = regioes;
        _isLoading = false;
        if (_regioes.isNotEmpty) {
          _selectedRegiao = _regioes.first;
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
      final familia = FamiliasCompanion(
        nomeResponsavel: Value(_nomeResponsavelController.text),
        telefone: Value(_telefoneController.text),
        endereco: Value(_enderecoController.text),
        regiaoId: Value(_selectedRegiao!.id),
      );

      await _familiasService.cadastrarFamilia(familia);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Família cadastrada com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar família: $e')),
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
        title: const Text('Cadastro de Família'),
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
                    DropdownButtonFormField<Regiao>(
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
                            : const Text('Cadastrar Família'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/database/app_database.dart';
import '../../core/services/familia_service.dart';
import '../../core/services/comunidade_service.dart';

/// Página para cadastro de novas famílias.
class _TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final limitedDigits = digits.substring(
      0,
      digits.length > 11 ? 11 : digits.length,
    );

    String formatted;
    if (limitedDigits.length <= 2) {
      formatted = '(${limitedDigits}';
    } else if (limitedDigits.length <= 7) {
      formatted =
          '(${limitedDigits.substring(0, 2)}) ${limitedDigits.substring(2)}';
    } else if (limitedDigits.length <= 10) {
      formatted =
          '(${limitedDigits.substring(0, 2)}) ${limitedDigits.substring(2, 6)}-${limitedDigits.substring(6)}';
    } else {
      formatted =
          '(${limitedDigits.substring(0, 2)}) ${limitedDigits.substring(2, 7)}-${limitedDigits.substring(7)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
  late ComunidadeService _comunidadesService;

  List<ComunidadeData> _comunidades = [];
  ComunidadeData? _selectedComunidade;
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
    _comunidadesService = ComunidadeService(db);
    await _loadComunidades();

    // Se estiver editando, preencher os campos
    if (_isEditing) {
      _nomeResponsavelController.text = widget.familia!.nomeResponsavel;
      _telefoneController.text = widget.familia!.telefone;
      _enderecoController.text = widget.familia!.endereco;
    }
  }

  Future<void> _loadComunidades() async {
    try {
      final comunidades = await _comunidadesService.getTodas();
      setState(() {
        _comunidades = comunidades;
        _isLoading = false;
        if (_comunidades.isNotEmpty) {
          if (_isEditing) {
            _selectedComunidade = _comunidades.firstWhere(
              (c) => c.id == widget.familia!.comunidadeId,
              orElse: () => _comunidades.first,
            );
          } else {
            _selectedComunidade = _comunidades.first;
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar comunidades: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedComunidade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma comunidade')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final familia = FamiliaCompanion(
        nomeResponsavel: Value(_nomeResponsavelController.text),
        telefone: Value(_telefoneController.text),
        endereco: Value(_enderecoController.text),
        comunidadeId: Value(_selectedComunidade!.id),
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
        final mensagem = e is StateError
            ? e.message
            : 'Erro ao ${_isEditing ? 'atualizar' : 'cadastrar'} família.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem)),
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _TelefoneInputFormatter(),
                      ],
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
                    DropdownButtonFormField<ComunidadeData>(
                      value: _selectedComunidade,
                      decoration: const InputDecoration(
                        labelText: 'Comunidade',
                        border: OutlineInputBorder(),
                      ),
                      items: _comunidades
                          .map((comunidade) => DropdownMenuItem(
                                value: comunidade,
                                child: Text(comunidade.nome),
                              ))
                          .toList(),
                      onChanged: (comunidade) {
                        setState(() => _selectedComunidade = comunidade);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Comunidade é obrigatória';
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

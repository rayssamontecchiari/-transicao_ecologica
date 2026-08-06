import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/comunidade_service.dart';

/// Pagina para cadastro de uma nova comunidade.
class CadastroComunidadePage extends StatefulWidget {
  const CadastroComunidadePage({super.key});

  @override
  State<CadastroComunidadePage> createState() => _CadastroComunidadePageState();
}

class _CadastroComunidadePageState extends State<CadastroComunidadePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  bool _isSaving = false;
  late ComunidadeService _comunidadesService;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final db = await AppDatabase.instance();
    _comunidadesService = ComunidadeService(db);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final comunidade = ComunidadeCompanion(
        nome: Value(_nomeController.text.trim()),
      );
      await _comunidadesService.inserir(comunidade);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comunidade cadastrada com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar comunidade: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Comunidade')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cadastre uma nova comunidade para organizar familias e avaliacoes.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Comunidade',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome e obrigatorio';
                  }
                  return null;
                },
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Cadastrar Comunidade'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

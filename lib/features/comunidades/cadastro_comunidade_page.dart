import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/comunidade_service.dart';

/// Pagina para cadastro ou edição de uma comunidade.
class CadastroComunidadePage extends StatefulWidget {
  final ComunidadeData? comunidade;

  const CadastroComunidadePage({super.key, this.comunidade});

  @override
  State<CadastroComunidadePage> createState() => _CadastroComunidadePageState();
}

class _CadastroComunidadePageState extends State<CadastroComunidadePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  bool _isSaving = false;
  late ComunidadeService _comunidadesService;

  bool get _isEditing => widget.comunidade != null;

  @override
  void initState() {
    super.initState();
    _initService();
    if (_isEditing) {
      _nomeController.text = widget.comunidade!.nome;
    }
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

      if (_isEditing) {
        await _comunidadesService.atualizarComunidade(
          widget.comunidade!.id,
          comunidade,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comunidade atualizada com sucesso!')),
          );
        }
      } else {
        await _comunidadesService.inserir(comunidade);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comunidade cadastrada com sucesso!')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao ${_isEditing ? 'atualizar' : 'cadastrar'} comunidade: $e',
            ),
          ),
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
      appBar: AppBar(
        title:
            Text(_isEditing ? 'Editar Comunidade' : 'Cadastro de Comunidade'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing
                    ? 'Atualize o nome da comunidade.'
                    : 'Cadastre uma nova comunidade para organizar famílias e avaliações.',
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
                    return 'Nome é obrigatório';
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
                      : Text(_isEditing
                          ? 'Salvar Alterações'
                          : 'Cadastrar Comunidade'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

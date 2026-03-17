import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/familia_service.dart';
import '../../core/services/avaliacao_service.dart';

class FamiliaDetalhesPage extends StatefulWidget {
  final int familiaId;

  const FamiliaDetalhesPage({
    super.key,
    required this.familiaId,
  });

  @override
  State<FamiliaDetalhesPage> createState() => _FamiliaDetalhesPageState();
}

class _FamiliaDetalhesPageState extends State<FamiliaDetalhesPage> {
  late AppDatabase _db;
  late FamiliasService _familiasService;
  late AvaliacaoService _avaliacaoService;

  Familia? _familia;
  List<Avaliacao> _avaliacoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _familiasService = FamiliasService(_db);
    _avaliacaoService = AvaliacaoService(_db);

    await _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);

    try {
      // Buscar família
      final familia = await (_db.select(_db.familias)
            ..where((f) => f.id.equals(widget.familiaId)))
          .getSingleOrNull();

      // Buscar avaliações
      final avaliacoes =
          await _avaliacaoService.getAvaliacoesPorFamilia(widget.familiaId);

      if (mounted) {
        setState(() {
          _familia = familia;
          _avaliacoes = avaliacoes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletarAvaliacao(int avaliacaoId) async {
    await _avaliacaoService.deletarAvaliacao(avaliacaoId);
    await _carregarDados();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Avaliação deletada'),
        ),
      );
    }
  }

  void _confirmarDelecao(int avaliacaoId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar deleção'),
        content: const Text('Tem certeza que deseja deletar esta avaliação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletarAvaliacao(avaliacaoId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Família'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _familia == null
              ? const Center(child: Text('Família não encontrada'))
              : RefreshIndicator(
                  onRefresh: _carregarDados,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// ===== CARD DADOS DA FAMÍLIA =====
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _familia!.nomeResponsavel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text('ID: ${_familia!.id}'),
                                if (_familia!.telefone != null)
                                  Text('Telefone: ${_familia!.telefone}'),
                                if (_familia!.endereco != null)
                                  Text('Endereço: ${_familia!.endereco}'),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// ===== AVALIAÇÕES =====
                        Text(
                          'Avaliações (${_avaliacoes.length})',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 16),

                        if (_avaliacoes.isEmpty)
                          Card(
                            color: Colors.grey[100],
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Nenhuma avaliação registrada',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _avaliacoes.length,
                            itemBuilder: (context, index) {
                              final avaliacao = _avaliacoes[index];
                              final data = avaliacao.data;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  child: ListTile(
                                    title: Text(avaliacao.avaliador),
                                    subtitle: Text(
                                      '${data.day}/${data.month}/${data.year} '
                                      'às ${data.hour}:${data.minute.toString().padLeft(2, '0')}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _confirmarDelecao(avaliacao.id),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

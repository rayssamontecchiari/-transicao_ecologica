import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column, Table;

import '../../core/database/app_database.dart';
import '../../core/services/resultado_avaliacao_service.dart';
import '../../core/models/resultado_avaliacao.dart';
import 'resultados_avaliacao_page.dart';

class TodasAvaliacoesPage extends StatefulWidget {
  const TodasAvaliacoesPage({super.key});

  @override
  State<TodasAvaliacoesPage> createState() => _TodasAvaliacoesPageState();
}

class _TodasAvaliacoesPageState extends State<TodasAvaliacoesPage> {
  late AppDatabase _db;
  late ResultadoAvaliacaoService _resultadoService;
  bool _isLoading = true;
  List<_AvaliacaoComResultados> _avaliacoes = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _resultadoService = ResultadoAvaliacaoService(_db);

    final familias = await _db.select(_db.familia).get();
    final familiaNomes = {
      for (final familia in familias) familia.id: familia.nomeResponsavel,
    };

    final avaliacoes = await (_db.select(_db.avaliacao)
          ..orderBy([
            (a) => OrderingTerm(expression: a.data, mode: OrderingMode.desc)
          ]))
        .get();

    final avaliacoesComResultados = <_AvaliacaoComResultados>[];

    for (final avaliacao in avaliacoes) {
      final stats =
          await _resultadoService.obterEstatisticasAvaliacao(avaliacao.id);
      avaliacoesComResultados.add(
        _AvaliacaoComResultados(
          item: avaliacao,
          familiaNome: familiaNomes[avaliacao.familiaId] ??
              'Família ${avaliacao.familiaId}',
          media: stats.isNotEmpty ? stats['media'] as double? : null,
          minValor: stats.isNotEmpty ? stats['minValor'] as double? : null,
          maxValor: stats.isNotEmpty ? stats['maxValor'] as double? : null,
          resultados: stats.isNotEmpty
              ? stats['resultados'] as List<ResultadoAvaliacao>?
              : null,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _avaliacoes = avaliacoesComResultados;
        _isLoading = false;
      });
    }
  }

  Color _obterCorPorValor(double? valor) {
    if (valor == null) return Colors.grey;
    if (valor >= 8.0) return Colors.green;
    if (valor >= 6.0) return Colors.blue;
    if (valor >= 4.0) return Colors.orange;
    if (valor >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as Avaliações'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _avaliacoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assessment_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma avaliação registrada ainda',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _avaliacoes.length,
                  itemBuilder: (context, index) {
                    final item = _avaliacoes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              _obterCorPorValor(item.media).withOpacity(0.16),
                          child: Icon(
                            Icons.checklist_rtl,
                            color: _obterCorPorValor(item.media),
                          ),
                        ),
                        title: Text(item.familiaNome),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatarData(item.item.data)),
                            const SizedBox(height: 4),
                            Text(
                              'Avaliador: ${item.item.avaliador}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: item.media != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.media!.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _obterCorPorValor(item.media),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Média',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              )
                            : null,
                        onTap: item.resultados != null
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ResultadosAvaliacaoPage(
                                      avaliacaoId: item.item.id,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    );
                  },
                ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}

class _AvaliacaoComResultados {
  final AvaliacaoData item;
  final String familiaNome;
  final double? media;
  final double? minValor;
  final double? maxValor;
  final List<ResultadoAvaliacao>? resultados;

  _AvaliacaoComResultados({
    required this.item,
    required this.familiaNome,
    required this.media,
    required this.minValor,
    required this.maxValor,
    required this.resultados,
  });
}

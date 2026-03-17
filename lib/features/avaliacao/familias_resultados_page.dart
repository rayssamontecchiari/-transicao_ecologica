import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/services/familia_service.dart';
import '../../core/services/resultado_avaliacao_service.dart';
import 'familia_resultados_detalhes_page.dart';

/// Página que lista famílias e permite visualizar seus resultados de avaliação
class FamiliasResultadosPage extends StatefulWidget {
  const FamiliasResultadosPage({super.key});

  @override
  State<FamiliasResultadosPage> createState() => _FamiliasResultadosPageState();
}

class _FamiliasResultadosPageState extends State<FamiliasResultadosPage> {
  late AppDatabase _db;
  late FamiliasService _familiasService;
  late ResultadoAvaliacaoService _resultadoService;

  bool _isLoading = true;
  List<_FamiliaComResultados> _familias = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _familiasService = FamiliasService(_db);
    _resultadoService = ResultadoAvaliacaoService(_db);

    final familias = await _familiasService.getTodas();

    List<_FamiliaComResultados> familiasComResultados = [];

    for (final familia in familias) {
      // Obter todas as avaliações dessa família
      final avaliacoes = await (_db.select(_db.avaliacoes)
            ..where((a) => a.familiaId.equals(familia.id)))
          .get();

      final totalAvaliacoes = avaliacoes.length;
      final ultimaAvaliacao = avaliacoes.isNotEmpty
          ? avaliacoes.reduce(
              (curr, next) => curr.data.isAfter(next.data) ? curr : next)
          : null;

      // Calcular média das últimas avaliações
      double? mediaUltima;
      if (ultimaAvaliacao != null) {
        final stats = await _resultadoService
            .obterEstatisticasAvaliacao(ultimaAvaliacao.id);
        if (stats.isNotEmpty && stats.containsKey('media')) {
          mediaUltima = stats['media'] as double?;
        }
      }

      familiasComResultados.add(
        _FamiliaComResultados(
          familia: familia,
          totalAvaliacoes: totalAvaliacoes,
          ultimaAvaliacao: ultimaAvaliacao,
          mediaUltima: mediaUltima,
        ),
      );
    }

    // Ordenar por data da última avaliação (mais recente primeiro)
    familiasComResultados.sort((a, b) {
      if (a.ultimaAvaliacao == null && b.ultimaAvaliacao == null) return 0;
      if (a.ultimaAvaliacao == null) return 1;
      if (b.ultimaAvaliacao == null) return -1;
      return b.ultimaAvaliacao!.data.compareTo(a.ultimaAvaliacao!.data);
    });

    setState(() {
      _familias = familiasComResultados;
      _isLoading = false;
    });
  }

  Color _obterCorPorMedia(double? media) {
    if (media == null) return Colors.grey;
    if (media >= 8.0) return Colors.green;
    if (media >= 6.0) return Colors.blue;
    if (media >= 4.0) return Colors.orange;
    if (media >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados por Família'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _familias.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.family_restroom,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma família cadastrada',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _familias.length,
                  itemBuilder: (context, index) {
                    final item = _familias[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: const Icon(Icons.people),
                        ),
                        title: Text(item.familia.nomeResponsavel),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Avaliações: ${item.totalAvaliacoes}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (item.ultimaAvaliacao != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Última: ${_formatarData(item.ultimaAvaliacao!.data)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                            if (item.mediaUltima != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Média: ${item.mediaUltima!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _obterCorPorMedia(item.mediaUltima),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                        onTap: item.totalAvaliacoes > 0
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FamiliaResultadosDetalhesPage(
                                      familia: item.familia,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        enabled: item.totalAvaliacoes > 0,
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

class _FamiliaComResultados {
  final Familia familia;
  final int totalAvaliacoes;
  final Avaliacao? ultimaAvaliacao;
  final double? mediaUltima;

  _FamiliaComResultados({
    required this.familia,
    required this.totalAvaliacoes,
    required this.ultimaAvaliacao,
    required this.mediaUltima,
  });
}

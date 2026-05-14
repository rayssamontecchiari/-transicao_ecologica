import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/models/resultado_avaliacao.dart';
import '../../core/services/resultado_avaliacao_service.dart';

/// Página para exibir os resultados da avaliação completa
class ResultadoAvaliacaoPage extends StatefulWidget {
  final int avaliacaoId;
  final Familia familia;

  const ResultadoAvaliacaoPage({
    super.key,
    required this.avaliacaoId,
    required this.familia,
  });

  @override
  State<ResultadoAvaliacaoPage> createState() => _ResultadoAvaliacaoPageState();
}

class _ResultadoAvaliacaoPageState extends State<ResultadoAvaliacaoPage> {
  late AppDatabase _db;
  late ResultadoAvaliacaoService _resultadoService;

  List<ResultadoAvaliacao> _resultados = [];
  Map<int, Categoria> _categoriaMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _resultadoService = ResultadoAvaliacaoService(_db);

    try {
      final resultados =
          await _resultadoService.calcularResultadosCompletos(widget.avaliacaoId);
      final categorias = await _db.select(_db.categorias).get();

      // Mapear categorias por ID
      final mapa = {for (var cat in categorias) cat.id: cat};

      setState(() {
        _resultados = resultados;
        _categoriaMap = mapa;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao calcular resultados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados da Avaliação'),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cabeçalho com informações da avaliação
                    Card(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumo da Avaliação',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.home, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Família ${widget.familia.id} - ${widget.familia.nomeResponsavel}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    size: 18, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_resultados.length} fatores avaliados',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (_resultados.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum resultado disponível',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Os dados da avaliação estão sendo processados.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._resultados.map((resultado) {
                        final categoria = _categoriaMap[resultado.categoriaId];
                        return _buildResultadoCard(resultado, categoria);
                      }).toList(),

                    const SizedBox(height: 24),

                    // Botão para voltar
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar'),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildResultadoCard(ResultadoAvaliacao resultado, Categoria? categoria) {
    final nomeCate = categoria?.nome ?? 'Categoria ${resultado.categoriaId}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da categoria
            Text(
              nomeCate,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Resultado Final (valor fuzzy)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resultado Final:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    resultado.valorFuzzyFinal.toStringAsFixed(4),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Expandable com detalhes do cálculo fuzzy
            ExpansionTile(
              title: const Text(
                'Parâmetros Fuzzy',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Parâmetro', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Valor', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: [
                        DataRow(cells: [
                          const DataCell(Text('Centroide')),
                          DataCell(Text(resultado.centroid.toStringAsFixed(4))),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Base')),
                          DataCell(Text(resultado.base.toStringAsFixed(4))),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Soma A')),
                          DataCell(Text(resultado.sumA.toStringAsFixed(4))),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Soma B')),
                          DataCell(Text(resultado.sumB.toStringAsFixed(4))),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Soma C')),
                          DataCell(Text(resultado.sumC.toStringAsFixed(4))),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Soma D')),
                          DataCell(Text(resultado.sumD.toStringAsFixed(4))),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

            const SizedBox(height: 12),

            // Indicador de qualidade baseado no resultado
            _buildQualityIndicator(resultado.valorFuzzyFinal),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityIndicator(double valor) {
    String qualidade;
    Color cor;
    IconData icone;

    if (valor < 0.2) {
      qualidade = 'Muito Baixo';
      cor = Colors.red;
      icone = Icons.trending_down;
    } else if (valor < 0.4) {
      qualidade = 'Baixo';
      cor = Colors.orange;
      icone = Icons.arrow_downward;
    } else if (valor < 0.6) {
      qualidade = 'Médio';
      cor = Colors.amber;
      icone = Icons.unfold_more;
    } else if (valor < 0.8) {
      qualidade = 'Bom';
      cor = Colors.lightGreen;
      icone = Icons.arrow_upward;
    } else {
      qualidade = 'Excelente';
      cor = Colors.green;
      icone = Icons.trending_up;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        border: Border.all(color: cor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              qualidade,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'categorias_service.dart';
import 'indicadores_service.dart';

/// Serviço de diagnóstico do banco de dados
class DatabaseDiagnostico {
  final CategoriasService categoriasService;
  final IndicadoresService indicadoresService;

  DatabaseDiagnostico({
    required this.categoriasService,
    required this.indicadoresService,
  });

  /// Verifica o estado dos dados no banco
  Future<Map<String, dynamic>> diagnosticar() async {
    try {
      final totalCategorias = await categoriasService.contarTotal();
      final totalIndicadores = await indicadoresService.contarTotal();
      final existeCategorias = await categoriasService.existeCategorias();
      final existeIndicadores = await indicadoresService.existeIndicadores();

      final categorias = await categoriasService.getTodas();
      final indicadoresMap = await indicadoresService.getPorCategoria();

      return {
        'sucesso': true,
        'totalCategorias': totalCategorias,
        'totalIndicadores': totalIndicadores,
        'existeCategorias': existeCategorias,
        'existeIndicadores': existeIndicadores,
        'categorias': categorias.map((c) => c.nome).toList(),
        'indicadoresMap': indicadoresMap,
        'mensagem': 'Banco de dados verificado com sucesso! ✓',
      };
    } catch (e) {
      return {
        'sucesso': false,
        'erro': e.toString(),
        'mensagem': 'Erro ao verifi car banco de dados',
      };
    }
  }

  /// Exibe um diálogo com o diagnóstico
  static Future<void> mostrarDiagnostico(
    BuildContext context,
    DatabaseDiagnostico diagnostico,
  ) async {
    final resultado = await diagnostico.diagnosticar();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnóstico do Banco'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                resultado['mensagem'] ?? 'Erro desconhecido',
                style: TextStyle(
                  color:
                      resultado['sucesso'] == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (resultado['sucesso'] == true) ...[
                _buildInfoRow(
                  'Categorias:',
                  '${resultado['totalCategorias']} cadastradas',
                ),
                _buildInfoRow(
                  'Indicadores:',
                  '${resultado['totalIndicadores']} cadastrados',
                ),
                if ((resultado['categorias'] as List?)?.isNotEmpty ??
                    false) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'Indicadores por Categoria:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ..._buildIndicadoresSection(
                      resultado['indicadoresMap'] as Map),
                ],
              ] else
                Text('Erro: ${resultado['erro']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  static List<Widget> _buildIndicadoresSection(Map indicadoresMap) {
    if (indicadoresMap.isEmpty) {
      return [const Text('Nenhum indicador cadastrado')];
    }

    final widgets = <Widget>[];
    int index = 0;

    indicadoresMap.forEach((categoria, indicadores) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoria.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              ...(indicadores as List).map((ind) => Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ind.nome,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if ((ind.descricao ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              ind.descricao ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      );

      if (index < indicadoresMap.length - 1) {
        widgets.add(const Divider());
      }
      index++;
    });

    return widgets;
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}

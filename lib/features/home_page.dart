import 'package:flutter/material.dart';
import 'package:transicao_ecologica/features/familias/familias_page.dart';

import '../core/database/app_database.dart';
import '../core/services/categorias_service.dart';
import '../core/services/indicadores_service.dart';
import '../core/services/database_diagnostico.dart';
import 'familias/cadastro_familia_page.dart';
import 'regioes/cadastro_regiao_page.dart';
import 'avaliacao/iniciar_avaliacao_page.dart';
import 'avaliacao/familias_resultados_page.dart';

/// Página inicial do aplicativo com imagem, título e botões de navegação.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _mostrarRelatorio(BuildContext context) async {
    final db = await AppDatabase.instance();
    final categoriasService = CategoriasService(db);
    final indicadoresService = IndicadoresService(db);

    final diagnostico = DatabaseDiagnostico(
      categoriasService: categoriasService,
      indicadoresService: indicadoresService,
    );

    if (context.mounted) {
      await DatabaseDiagnostico.mostrarDiagnostico(context, diagnostico);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transição Ecológica'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scrollbar(
          thumbVisibility: true, // deixa a barra sempre visível (opcional)
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/transicao_logo.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Avaliação transição agroecológica',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const IniciarAvaliacaoPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Adicionar Nova Avaliação'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FamiliasResultadosPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.assessment),
                      label: const Text('Ver Resultados'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FamiliasListPage(),
                          ),
                        );
                      },
                      child: const Text('Ver Famílias cadastradas'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CadastroFamiliaPage(),
                          ),
                        );
                      },
                      child: const Text('Cadastrar Família'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CadastroRegiaoPage(),
                          ),
                        );
                      },
                      child: const Text('Cadastrar Região'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _mostrarRelatorio(context),
                      icon: const Icon(Icons.assessment),
                      label: const Text('Relatório do Banco'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

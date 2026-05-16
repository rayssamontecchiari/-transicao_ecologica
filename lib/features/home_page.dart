import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transicao_ecologica/features/avaliacao/iniciar_avaliacao_page.dart';
import 'package:transicao_ecologica/features/familias/familias_page.dart';
import 'package:transicao_ecologica/features/configuracoes/gerenciar_pesos_page.dart';

import '../core/database/app_database.dart';
import '../core/services/categorias_service.dart';
import '../core/services/indicadores_service.dart';
import '../core/services/database_diagnostico.dart';
import '../core/services/resultado_avaliacao_service.dart';
import 'avaliacao/familias_resultados_page.dart';
import 'avaliacao/todas_avaliacoes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class DashboardStats {
  final int familiasCadastradas;
  final int avaliacoesRealizadas;
  final double mediaFuzzy;

  DashboardStats({
    required this.familiasCadastradas,
    required this.avaliacoesRealizadas,
    required this.mediaFuzzy,
  });
}

class _HomePageState extends State<HomePage> {
  late Future<DashboardStats> _statsFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _statsFuture = _carregarEstatisticas();
  }

  Future<DashboardStats> _carregarEstatisticas() async {
    final db = await AppDatabase.instance();
    final resultadoService = ResultadoAvaliacaoService(db);

    final familias = await db.select(db.familias).get();
    final avaliacoes = await db.select(db.avaliacoes).get();
    final concluido = avaliacoes.where((a) => a.status == 'completed').toList();

    double mediaFuzzy = 0.0;
    if (concluido.isNotEmpty) {
      final statsFuturas = await Future.wait(
        concluido.map((avaliacao) =>
            resultadoService.obterEstatisticasAvaliacao(avaliacao.id)),
      );
      final medias = statsFuturas
          .where((stats) => stats.containsKey('media'))
          .map((stats) => stats['media'] as double)
          .toList();
      if (medias.isNotEmpty) {
        mediaFuzzy = medias.reduce((a, b) => a + b) / medias.length;
      }
    }

    return DashboardStats(
      familiasCadastradas: familias.length,
      avaliacoesRealizadas: avaliacoes.length,
      mediaFuzzy: mediaFuzzy,
    );
  }

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

  Widget _buildStatCard(
    BuildContext context, {
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color.darken(0.1),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.24),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: FutureBuilder<DashboardStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              final stats = snapshot.data;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Boa tarde! 🌿',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sistema de Avaliação Agroecológica',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Column(
                      children: [
                        _buildFeatureCard(
                          context,
                          icon: Icons.people_alt,
                          title: 'Famílias',
                          subtitle: 'Acesse e gerencie a lista de famílias.',
                          color: const Color(0xFF388E3C),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FamiliasListPage(),
                              ),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.checklist_rtl,
                          title: 'Avaliações',
                          subtitle:
                              'Veja e acompanhe todas as avaliações realizadas.',
                          color: const Color(0xFF1976D2),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TodasAvaliacoesPage(),
                              ),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.plus_one_outlined,
                          title: 'Iniciar nova avaliação',
                          subtitle: 'Crie uma nova avaliação para uma família.',
                          color: const Color(0xFF1976D2),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const IniciarAvaliacaoPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Resumo Geral',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          value: stats != null
                              ? stats.familiasCadastradas.toString()
                              : '--',
                          label: 'Famílias cadastradas',
                          color: const Color(0xFF388E3C),
                        ),
                        _buildStatCard(
                          context,
                          value: stats != null
                              ? stats.avaliacoesRealizadas.toString()
                              : '--',
                          label: 'Avaliações realizadas',
                          color: const Color(0xFF1976D2),
                        ),
                        _buildStatCard(
                          context,
                          value: stats != null
                              ? stats.mediaFuzzy.toStringAsFixed(1)
                              : '--',
                          label: 'Média geral dos resultados',
                          color: const Color(0xFFFBC02D),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const LinearProgressIndicator(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TodasAvaliacoesPage(),
                ),
              );
              break;
            case 2:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FamiliasResultadosPage(),
                ),
              );
              break;
            case 3:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GerenciarPesosPage(),
                ),
              );
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rtl),
            label: 'Avaliações',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Resultados',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}

extension on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

import 'package:flutter/material.dart';
import 'package:transicao_ecologica/features/familias/familias_page.dart';

import '../core/database/app_database.dart';
import '../core/services/categorias_service.dart';
import '../core/services/indicadores_service.dart';
import '../core/services/database_diagnostico.dart';
import '../core/services/resultado_avaliacao_service.dart';
import 'avaliacao/iniciar_avaliacao_page.dart';
import 'avaliacao/familias_resultados_page.dart';
import 'exportacao/export_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class DashboardStats {
  final int familiasCadastradas;
  final int avaliacoesRealizadas;
  final int avaliacoesPendentes;
  final double mediaFuzzy;

  DashboardStats({
    required this.familiasCadastradas,
    required this.avaliacoesRealizadas,
    required this.avaliacoesPendentes,
    required this.mediaFuzzy,
  });
}

class _HomePageState extends State<HomePage> {
  late Future<DashboardStats> _statsFuture;

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
    final pendentes = avaliacoes.where((a) => a.status == 'draft').length;
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
      avaliacoesPendentes: pendentes,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              colorScheme.primary.withOpacity(0.16),
                          child: Icon(
                            Icons.person,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.95),
                            colorScheme.primary.withOpacity(0.72),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nova Avaliação',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Inicie uma nova avaliação da transição agroecológica da família.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const IniciarAvaliacaoPage(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Iniciar Avaliação'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const LinearProgressIndicator(),
                    const SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
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
                        ],
                      ),
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildStatCard(
                            context,
                            value: stats != null
                                ? stats.mediaFuzzy.toStringAsFixed(1)
                                : '--',
                            label: 'Média fuzzy geral',
                            color: const Color(0xFFFBC02D),
                          ),
                          _buildStatCard(
                            context,
                            value: stats != null
                                ? stats.avaliacoesPendentes.toString()
                                : '--',
                            label: 'Avaliações pendentes',
                            color: const Color(0xFFD32F2F),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildFactorCard(
                            context,
                            icon: Icons.eco,
                            title: 'Sustentabilidade',
                            subtitle:
                                'Uso responsável dos recursos e conservação do ambiente.',
                            color: const Color(0xFF388E3C),
                          ),
                          _buildFactorCard(
                            context,
                            icon: Icons.person,
                            title: 'Campesinidade',
                            subtitle:
                                'Identidade, saberes e forma camponesa de produzir.',
                            color: const Color(0xFF7CB342),
                          ),
                        ],
                      ),
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildFactorCard(
                            context,
                            icon: Icons.group,
                            title: 'Organização Social',
                            subtitle:
                                'Cooperação, participação e fortalecimento social.',
                            color: const Color(0xFF1976D2),
                          ),
                          _buildFactorCard(
                            context,
                            icon: Icons.bar_chart,
                            title: 'Agência Rural',
                            subtitle:
                                'Capacidade de gestão, inovação e tomada de decisões.',
                            color: const Color(0xFF8E24AA),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const FamiliasListPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.people_alt),
                            label: const Text('Ver Famílias Cadastradas'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const FamiliasResultadosPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.insert_chart_outlined),
                            label: const Text('Ver Resultados e Relatórios'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ExportPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.file_download_outlined),
                      label: const Text('Exportar Dados'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
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

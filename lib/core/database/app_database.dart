import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/regioes_table.dart';
import 'tables/familias_table.dart';
import 'tables/categorias_table.dart';
import 'tables/dimensoes_table.dart';
import 'tables/praticas_table.dart';
import 'tables/indicadores_table.dart';
import 'tables/avaliacoes_table.dart';
import 'tables/avaliacao_itens_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Regioes,
    Familias,
    Categorias,
    Dimensoes,
    Praticas,
    Indicadores,
    Avaliacoes,
    AvaliacaoItens,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(QueryExecutor e) : super(e);

  static AppDatabase? _instance;

  static Future<AppDatabase> instance() async {
    if (_instance != null) return _instance!;
    final executor = await _openConnection();
    _instance = AppDatabase._internal(executor);
    return _instance!;
  }

  @override
  int get schemaVersion => 3;

  /// We override [migration] so we can insert seed data when the database is
  /// first created. This ensures every install starts with the same base
  /// information; the values can also be modified directly with SQL later.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();

          // Seed default regions and categories. Add more entries here as needed.
          await into(regioes).insert(RegioesCompanion.insert(nome: 'Norte'));
          await into(regioes).insert(RegioesCompanion.insert(nome: 'Sul'));
          await into(regioes).insert(RegioesCompanion.insert(nome: 'Leste'));
          await into(regioes).insert(RegioesCompanion.insert(nome: 'Oeste'));

          // --- categories ---
          await into(categorias).insert(CategoriasCompanion.insert(
              nome: 'Grau de campesinidade × agroindustrialização',
              descricao: Value('modo de vida, valores e práticas camponesas')));
          await into(categorias).insert(CategoriasCompanion.insert(
              nome:
                  'Análise Multidimensional da Sustentabilidade das Práticas Agrícolas',
              descricao: Value('ambiental, social e econômica')));
          await into(categorias).insert(CategoriasCompanion.insert(
              nome: 'Organização social',
              descricao: Value('associações, cooperativas, ação coletiva')));
          await into(categorias).insert(CategoriasCompanion.insert(
              nome: 'Agenciamento do desenvolvimento rural',
              descricao: Value(
                  'capacidade dos atores locais de conduzir seu próprio desenvolvimento')));

          // --- initial indicators for first category ---
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Energia',
            descricao:
                'Intensidade energética: uso de máquinas, combustíveis e fertilizantes sintéticos',
            peso: Value(1.0),
            categoriaId: 1,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Escala',
            descricao:
                'Área de produção e prevalência de monocultura versus parcelas pequenas e diversificadas',
            peso: Value(1.0),
            categoriaId: 1,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Autossuficiência / Dependência de insumos',
            descricao:
                'Proporção de insumos externos (adubos químicos, agrotóxicos, sementes comerciais) versus insumos locais',
            peso: Value(1.0),
            categoriaId: 1,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Força de trabalho',
            descricao:
                'Predominância de mão de obra familiar versus contratação de terceiros',
            peso: Value(1.0),
            categoriaId: 1,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Agrobiodiversidade',
            descricao:
                'Diversidade de espécies/variedades e uso de sementes locais versus híbridas/transgênicas',
            peso: Value(1.0),
            categoriaId: 1,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Produtividade ecológica / Grau de artificialização',
            descricao:
                'Presença de elementos naturais, matéria orgânica do solo e práticas agroecológicas',
            peso: Value(1.0),
            categoriaId: 1,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Multifuncionalidade do trabalho',
            descricao:
                'Diversificação das atividades, presença de autoconsumo e serviços locais',
            peso: Value(1.0),
            categoriaId: 1,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Conhecimento',
            descricao:
                'Predominância de saberes tradicionais adaptados localmente versus pacotes tecnológicos',
            peso: Value(1.0),
            categoriaId: 1,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Cosmovisão',
            descricao:
                'Visão de mundo: antropocêntrica/pragmática versus harmônica/integrada',
            peso: Value(1.0),
            categoriaId: 1,
          ));

          // --- data specific to the "Análise Multidimensional" category ---
          // find the id of the category we just created because inserts are
          // sequential but we want a more robust lookup
          final cat2 = await (select(categorias)
                ..where((c) => c.nome.equals(
                    'Análise Multidimensional da Sustentabilidade das Práticas Agrícolas')))
              .getSingle();

          // dimensions
          final ecolDim = await into(dimensoes).insertReturning(
              DimensoesCompanion.insert(
                  nome: 'Ecológica', categoriaId: cat2.id));
          final socDim = await into(dimensoes).insertReturning(
              DimensoesCompanion.insert(nome: 'Social', categoriaId: cat2.id));
          final econDim = await into(dimensoes).insertReturning(
              DimensoesCompanion.insert(
                  nome: 'Econômica', categoriaId: cat2.id));

          // aspects / indicadores por dimensão
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome:
                'Conservação ou melhoria das condições químicas, físicas e biológicas do solo',
            descricao: '...',
            peso: Value(1.0),
            categoriaId: cat2.id,
            dimensaoId: Value(ecolDim.id),
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome:
                'Manutenção ou melhoria da agrobiodiversidade e dos recursos hídricos',
            descricao: '...',
            peso: Value(1.0),
            categoriaId: cat2.id,
            dimensaoId: Value(ecolDim.id),
          ));

          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome:
                'Melhoria da qualidade de vida pela eliminação do uso de insumos tóxicos',
            descricao: '...',
            peso: Value(1.0),
            categoriaId: cat2.id,
            dimensaoId: Value(socDim.id),
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome:
                'Melhoria da qualidade de vida pelo menor uso de mão de obra e redução da penosidade do trabalho devido a melhor ergonomia',
            descricao: '...',
            peso: Value(1.0),
            categoriaId: cat2.id,
            dimensaoId: Value(socDim.id),
          ));

          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Baixo consumo de energias não renováveis',
            descricao: '...',
            peso: Value(1.0),
            categoriaId: cat2.id,
            dimensaoId: Value(econDim.id),
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Geração de renda com menor dependência de insumos externos',
            descricao: '...',
            peso: Value(1.0),
            categoriaId: cat2.id,
            dimensaoId: Value(econDim.id),
          ));

          // agricultural practices
          const praticasNomes = [
            'Controle de ervas espontâneas',
            'Preparo do solo',
            'Adubação verde',
            'Calagem e adubação',
            'Controle de pragas e doenças',
            'Sementes e mudas',
            'Irrigação',
            'Sistema de cultivo',
          ];

          for (final nome in praticasNomes) {
            await into(praticas).insert(
                PraticasCompanion.insert(nome: nome, categoriaId: cat2.id));
          }

          // --- indicators for "Organização social" category ---
          final cat3 = await (select(categorias)
                ..where((c) => c.nome.equals('Organização social')))
              .getSingle();

          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Participação',
            descricao:
                'Nível de participação nas atividades de interesse comum das organizações comunitárias (discussões nas reuniões, planejamento de eventos, construção de propostas, elaboração e implantação de projetos).',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Representatividade',
            descricao:
                'Diversidade de opinião, raça, crença, nível educacional, cultura, gênero e geração entre os membros.',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Representação',
            descricao:
                'Forma como o presidente representa a organização e envolve os demais membros, delegando funções com a criação de comissões específicas e permanentes.',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Planejamento e gestão',
            descricao:
                'Elaboração de diagnósticos, planejamento de ações e projetos a partir de planos de curto, médio e longo prazo com monitoramento e avaliação.',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Transparência',
            descricao:
                'Disponibilidade de atas, prestações de contas e documentos ao público. Exposição de planejamento e resultados em painéis acessíveis.',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Decisão',
            descricao:
                'Tomada de decisão através de processos dialógicos e democráticos visando consenso, com métodos como circularidade da fala e escuta ativa.',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Disposição dos participantes nas reuniões',
            descricao:
                'Arranjo físico das reuniões em círculo sem lugar de destaque, onde todos ensinam e aprendem caracterizando a singularidade dos saberes.',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Temas relevantes',
            descricao:
                'Abordagem de temas prioritários hierarquizados para discussão em comissões permanentes. Capacitação técnica e política em diversos temas.',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Formação',
            descricao:
                'Promoção de oficinas, palestras temáticas e atividades de formação continuada para capacitação dos associados.',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Sucessão',
            descricao:
                'Renovação regular dos quadros da diretoria com eleições periódicas, evitando permanência indefinida do mesmo grupo.',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Empoderamento',
            descricao:
                'Ocupação de espaços de representação em conselhos, comitês e fóruns regionais pela organização e seus representantes.',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));

          // --- indicators for "Agenciamento do desenvolvimento rural" category ---
          final cat4 = await (select(categorias)
                ..where((c) =>
                    c.nome.equals('Agenciamento do desenvolvimento rural')))
              .getSingle();

          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Ações coletivas em unidade de produção',
            descricao:
                'Reuniões técnicas, demonstrações de método e dias de campo realizados na propriedade. Nota máxima: 5.0 (0.2 para cada um ou dois eventos anuais, iniciando em 4.2).',
            peso: Value(5.0),
            categoriaId: cat4.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Orientação técnica individual em unidade de produção',
            descricao:
                'Visitas técnicas individuais e acompanhamento direto na propriedade. Nota máxima: 4.0 (0.2 para cada um ou dois eventos anuais, iniciando em 3.2).',
            peso: Value(4.0),
            categoriaId: cat4.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Ações coletivas em associações, sindicatos e organizações',
            descricao:
                'Participação em eventos coletivos realizados por associações, sindicatos e outras organizações. Nota máxima: 3.0 (0.2 para cada um ou dois eventos anuais, iniciando em 2.2).',
            peso: Value(3.0),
            categoriaId: cat4.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Orientação técnica individual em loja ou escritório',
            descricao:
                'Atendimento técnico em espaços comerciais ou de escritório. Nota máxima: 2.0 (0.2 para cada um ou dois eventos anuais, iniciando em 1.2).',
            peso: Value(2.0),
            categoriaId: cat4.id,
          ));
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Informação esporádica de fonte diversa',
            descricao:
                'Acesso ocasional a informações advindas de diferentes fontes (internet, rádio, vizinhos, etc.). Nota máxima: 1.0 (sem variação).',
            peso: Value(1.0),
            categoriaId: cat4.id,
          ));
        },
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            // version 2 adds new tables and a column on `indicadores`
            await m.createTable(dimensoes);
            await m.createTable(praticas);
            await m.addColumn(indicadores, indicadores.dimensaoId);
            from = 2; // continue upgrading to next versions if needed
          }

          if (from == 2) {
            // version 3 adds a praticaId to evaluation items (multidimensional
            // grid scoring)
            await m.addColumn(avaliacaoItens, avaliacaoItens.praticaId);
          }
        },
      );
}

Future<QueryExecutor> _openConnection() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'db.sqlite'));
  return NativeDatabase(file);
}

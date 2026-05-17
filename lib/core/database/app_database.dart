import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/regiao_table.dart';
import 'tables/familia_table.dart';
import 'tables/categoria_table.dart';
import 'tables/dimensao_table.dart';
import 'tables/pratica_table.dart';
import 'tables/indicador_table.dart';
import 'tables/avaliacao_table.dart';
import 'tables/avaliacao_item_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Regiao,
    Familia,
    Categoria,
    Dimensao,
    Pratica,
    Indicador,
    Avaliacao,
    AvaliacaoItem,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.e);

  static AppDatabase? _instance;

  static Future<AppDatabase> instance() async {
    if (_instance != null) return _instance!;
    final executor = await _openConnection();
    _instance = AppDatabase._internal(executor);
    return _instance!;
  }

  @override
  int get schemaVersion => 5;

  /// We override [migration] so we can insert seed data when the database is
  /// first created. This ensures every install starts with the same base
  /// information; the values can also be modified directly with SQL later.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();

          // Seed default regions and categories. Add more entries here as needed.
          await into(regiao).insert(RegiaoCompanion.insert(nome: 'Norte'));
          await into(regiao).insert(RegiaoCompanion.insert(nome: 'Sul'));
          await into(regiao).insert(RegiaoCompanion.insert(nome: 'Leste'));
          await into(regiao).insert(RegiaoCompanion.insert(nome: 'Oeste'));

          // --- categories ---
          await into(categoria).insert(CategoriaCompanion.insert(
              nome: 'Grau de campesinidade × agroindustrialização',
              descricao: Value('modo de vida, valores e práticas camponesas')));
          await into(categoria).insert(CategoriaCompanion.insert(
              nome:
                  'Análise Multidimensional da Sustentabilidade das Práticas Agrícolas',
              descricao: Value('ambiental, social e econômica')));
          await into(categoria).insert(CategoriaCompanion.insert(
              nome: 'Organização social',
              descricao: Value('associações, cooperativas, ação coletiva')));
          await into(categoria).insert(CategoriaCompanion.insert(
              nome: 'Agenciamento do desenvolvimento rural',
              descricao: Value(
                  'capacidade dos atores locais de conduzir seu próprio desenvolvimento')));

          // --- initial indicators for first category ---
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Energia',
            descricao:
                'Intensidade energética: uso de máquinas, combustíveis e fertilizantes sintéticos',
            peso: Value(1.0),
            categoriaId: 1,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Escala',
            descricao:
                'Área de produção e prevalência de monocultura versus parcelas pequenas e diversificadas',
            peso: Value(0.5),
            categoriaId: 1,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Autossuficiência / Dependência de insumos',
            descricao:
                'Proporção de insumos externos (adubos químicos, agrotóxicos, sementes comerciais) versus insumos locais',
            peso: Value(0.8),
            categoriaId: 1,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Força de trabalho',
            descricao:
                'Predominância de mão de obra familiar versus contratação de terceiros',
            peso: Value(0.8),
            categoriaId: 1,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Agrobiodiversidade',
            descricao:
                'Diversidade de espécies/variedades e uso de sementes locais versus híbridas/transgênicas',
            peso: Value(0.9),
            categoriaId: 1,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Produtividade ecológica / Grau de artificialização',
            descricao:
                'Presença de elementos naturais, matéria orgânica do solo e práticas agroecológicas',
            peso: Value(0.7),
            categoriaId: 1,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Multifuncionalidade do trabalho',
            descricao:
                'Diversificação das atividades, presença de autoconsumo e serviços locais',
            peso: Value(0.8),
            categoriaId: 1,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Conhecimento',
            descricao:
                'Predominância de saberes tradicionais adaptados localmente versus pacotes tecnológicos',
            peso: Value(0.9),
            categoriaId: 1,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Cosmovisão',
            descricao:
                'Visão de mundo: antropocêntrica/pragmática versus harmônica/integrada',
            peso: Value(0.6),
            categoriaId: 1,
          ));

          // --- data specific to the "Análise Multidimensional" category ---
          // find the id of the category we just created because inserts are
          // sequential but we want a more robust lookup
          final cat2 = await (select(categoria)
                ..where((c) => c.nome.equals(
                    'Análise Multidimensional da Sustentabilidade das Práticas Agrícolas')))
              .getSingle();

          // dimensions
          final ecolDim = await into(dimensao).insertReturning(
              DimensaoCompanion.insert(
                  nome: 'Ecológica', categoriaId: cat2.id));
          final socDim = await into(dimensao).insertReturning(
              DimensaoCompanion.insert(nome: 'Social', categoriaId: cat2.id));
          final econDim = await into(dimensao).insertReturning(
              DimensaoCompanion.insert(
                  nome: 'Econômica', categoriaId: cat2.id));

          // aspects / indicador por dimensão
          await into(indicador).insert(IndicadorCompanion.insert(
            nome:
                'Conservação ou melhoria das condições químicas, físicas e biológicas do solo',
            descricao: '...',
            peso: Value(1.0),
            categoriaId: cat2.id,
            dimensaoId: Value(ecolDim.id),
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome:
                'Manutenção ou melhoria da agrobiodiversidade e dos recursos hídricos',
            descricao: '...',
            peso: Value(1.0),
            categoriaId: cat2.id,
            dimensaoId: Value(ecolDim.id),
          ));

          await into(indicador).insert(IndicadorCompanion.insert(
            nome:
                'Melhoria da qualidade de vida pela eliminação do uso de insumos tóxicos',
            descricao: '...',
            peso: Value(1.0),
            categoriaId: cat2.id,
            dimensaoId: Value(socDim.id),
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome:
                'Melhoria da qualidade de vida pelo menor uso de mão de obra e redução da penosidade do trabalho devido a melhor ergonomia',
            descricao: '...',
            peso: Value(1.0),
            categoriaId: cat2.id,
            dimensaoId: Value(socDim.id),
          ));

          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Baixo consumo de energias não renováveis',
            descricao: '...',
            peso: Value(1.0),
            categoriaId: cat2.id,
            dimensaoId: Value(econDim.id),
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
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
            await into(pratica).insert(
                PraticaCompanion.insert(nome: nome, categoriaId: cat2.id));
          }

          // --- indicators for "Organização social" category ---
          final cat3 = await (select(categoria)
                ..where((c) => c.nome.equals('Organização social')))
              .getSingle();

          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Participação',
            descricao:
                'Nível de participação nas atividades de interesse comum das organizações comunitárias (discussões nas reuniões, planejamento de eventos, construção de propostas, elaboração e implantação de projetos).',
            peso: Value(1.0),
            categoriaId: cat3.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Representatividade',
            descricao:
                'Diversidade de opinião, raça, crença, nível educacional, cultura, gênero e geração entre os membros.',
            peso: Value(0.9),
            categoriaId: cat3.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Representação',
            descricao:
                'Forma como o presidente representa a organização e envolve os demais membros, delegando funções com a criação de comissões específicas e permanentes.',
            peso: Value(0.6),
            categoriaId: cat3.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Planejamento e gestão',
            descricao:
                'Elaboração de diagnósticos, planejamento de ações e projetos a partir de planos de curto, médio e longo prazo com monitoramento e avaliação.',
            peso: Value(0.8),
            categoriaId: cat3.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Transparência',
            descricao:
                'Disponibilidade de atas, prestações de contas e documentos ao público. Exposição de planejamento e resultados em painéis acessíveis.',
            peso: Value(0.9),
            categoriaId: cat3.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Decisão',
            descricao:
                'Tomada de decisão através de processos dialógicos e democráticos visando consenso, com métodos como circularidade da fala e escuta ativa.',
            peso: Value(0.8),
            categoriaId: cat3.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Disposição dos participantes nas reuniões',
            descricao:
                'Arranjo físico das reuniões em círculo sem lugar de destaque, onde todos ensinam e aprendem caracterizando a singularidade dos saberes.',
            peso: Value(0.5),
            categoriaId: cat3.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Temas relevantes',
            descricao:
                'Abordagem de temas prioritários hierarquizados para discussão em comissões permanentes. Capacitação técnica e política em diversos temas.',
            peso: Value(0.8),
            categoriaId: cat3.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Formação',
            descricao:
                'Promoção de oficinas, palestras temáticas e atividades de formação continuada para capacitação dos associados.',
            peso: Value(0.8),
            categoriaId: cat3.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Sucessão',
            descricao:
                'Renovação regular dos quadros da diretoria com eleições periódicas, evitando permanência indefinida do mesmo grupo.',
            peso: Value(0.7),
            categoriaId: cat3.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Empoderamento',
            descricao:
                'Ocupação de espaços de representação em conselhos, comitês e fóruns regionais pela organização e seus representantes.',
            peso: Value(0.7),
            categoriaId: cat3.id,
          ));

          // --- indicators for "Agenciamento do desenvolvimento rural" category ---
          final cat4 = await (select(categoria)
                ..where((c) =>
                    c.nome.equals('Agenciamento do desenvolvimento rural')))
              .getSingle();

          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Ações coletivas em unidade de produção',
            descricao:
                'Reuniões técnicas, demonstrações de método e dias de campo realizados na propriedade.',
            peso: Value(1.0),
            categoriaId: cat4.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Ação coletiva em organização',
            descricao:
                'Participação em eventos coletivos realizados por associações, sindicatos e outras organizações.',
            peso: Value(0.7),
            categoriaId: cat4.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Ação individual em unidade produtiva',
            descricao:
                'Visitas técnicas individuais e acompanhamento direto na propriedade.',
            peso: Value(0.6),
            categoriaId: cat4.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Ação individual em estabelecimento',
            descricao:
                'Atendimento técnico em espaços comerciais ou de escritório.',
            peso: Value(0.4),
            categoriaId: cat4.id,
          ));
          await into(indicador).insert(IndicadorCompanion.insert(
            nome: 'Ação educativa não disponibilizada',
            descricao:
                'Acesso ocasional a informações advindas de diferentes fontes.',
            peso: Value(0.11),
            categoriaId: cat4.id,
          ));
        },
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            // version 2 adds new tables and a column on `indicador`
            await m.createTable(dimensao);
            await m.createTable(pratica);
            await m.addColumn(indicador, indicador.dimensaoId);
            from = 2; // continue upgrading to next versions if needed
          }

          if (from == 2) {
            // version 3 adds a praticaId to evaluation items (multidimensional
            // grid scoring)
            await m.addColumn(avaliacaoItem, avaliacaoItem.praticaId);
          }

          if (from == 3) {
            // version 4 adds support for draft evaluations and editing
            // Use raw SQL to add new columns
            final executor = m.database;
            // Add columns - SQLite doesn't allow CURRENT_TIMESTAMP as default in ALTER TABLE
            await executor.customStatement(
              'ALTER TABLE avaliacoes ADD COLUMN data_alteracao DATETIME DEFAULT NULL',
            );
            await executor.customStatement(
              "ALTER TABLE avaliacoes ADD COLUMN status TEXT DEFAULT 'draft'",
            );
            // Note: previously we added `categoria_atual` here. That column is
            // being removed in schemaVersion 5, so we do NOT add it here.
            // Existing installs will be migrated below.
          }

          // Migrate to schemaVersion 5: rename plural tables to singular names.
          if (from < 5) {
            final executor = m.database;
            // We rename existing plural tables to backups, create the new
            // singular tables with `m.createAll()`, then copy data from the
            // backups into the new tables. This avoids FK constraint issues
            // and preserves data.
            await executor.customStatement('PRAGMA foreign_keys=OFF');
            await executor.customStatement('BEGIN TRANSACTION');

            // Rename existing plural tables to *_old if they exist.
            final tablesToRename = [
              'regioes',
              'familias',
              'categorias',
              'dimensoes',
              'praticas',
              'indicador',
              'avaliacoes',
              'avaliacao_itens'
            ];

            for (final t in tablesToRename) {
              await executor.customStatement(
                  "ALTER TABLE \"$t\" RENAME TO \"${t}_old\";");
            }

            // Create new tables (these will use the singular names defined in
            // the table classes via `tableName`).
            await m.createAll();

            // Copy data from old backups into new singular tables.
            await executor.customStatement('''
              INSERT INTO regiao (id, nome)
              SELECT id, nome FROM regioes_old;
            ''');

            await executor.customStatement('''
              INSERT INTO familia (id, nome_responsavel, telefone, endereco, regiao_id)
              SELECT id, nome_responsavel, telefone, endereco, regiao_id FROM familias_old;
            ''');

            await executor.customStatement('''
              INSERT INTO categoria (id, nome, descricao)
              SELECT id, nome, descricao FROM categorias_old;
            ''');

            await executor.customStatement('''
              INSERT INTO dimensao (id, nome, categoria_id)
              SELECT id, nome, categoria_id FROM dimensoes_old;
            ''');

            await executor.customStatement('''
              INSERT INTO pratica (id, nome, categoria_id)
              SELECT id, nome, categoria_id FROM praticas_old;
            ''');

            await executor.customStatement('''
              INSERT INTO indicador (id, nome, descricao, peso, categoria_id, dimensao_id)
              SELECT id, nome, descricao, peso, categoria_id, dimensao_id FROM indicador_old;
            ''');

            await executor.customStatement('''
              INSERT INTO avaliacao (id, data, data_alteracao, avaliador, observacoes, status, familia_id)
              SELECT id, data, data_alteracao, avaliador, observacoes, status, familia_id FROM avaliacoes_old;
            ''');

            await executor.customStatement('''
              INSERT INTO avaliacao_item (id, avaliacao_id, indicador_id, pratica_id, valor_likert, valor_fuzzy)
              SELECT id, avaliacao_id, indicador_id, pratica_id, valor_likert, valor_fuzzy FROM avaliacao_itens_old;
            ''');

            // Drop backups
            for (final t in tablesToRename) {
              await executor
                  .customStatement("DROP TABLE IF EXISTS \"${t}_old\";");
            }

            await executor.customStatement('COMMIT');
            await executor.customStatement('PRAGMA foreign_keys=ON');
          }
        },
      );
}

Future<QueryExecutor> _openConnection() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'db.sqlite'));
  print(file.path);
  return NativeDatabase(file);
}

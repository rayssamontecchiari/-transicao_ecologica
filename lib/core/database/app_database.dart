import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/comunidade_table.dart';
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
    Comunidade,
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

  Future<void> _rebuildAvaliacaoItemTableAllowingZeroLikert() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS avaliacao_item_new (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        avaliacao_id INTEGER NOT NULL REFERENCES avaliacao(id),
        indicador_id INTEGER NOT NULL REFERENCES indicador(id),
        pratica_id INTEGER NULL REFERENCES pratica(id),
        valor_likert INTEGER NULL CHECK (valor_likert BETWEEN 0 AND 5),
        valor_fuzzy REAL NULL
      )
    ''');

    await customStatement('''
      INSERT INTO avaliacao_item_new (
        id,
        avaliacao_id,
        indicador_id,
        pratica_id,
        valor_likert,
        valor_fuzzy
      )
      SELECT
        id,
        avaliacao_id,
        indicador_id,
        pratica_id,
        valor_likert,
        valor_fuzzy
      FROM avaliacao_item
    ''');

    await customStatement('DROP TABLE avaliacao_item');
    await customStatement(
        'ALTER TABLE avaliacao_item_new RENAME TO avaliacao_item');
  }

  Future<void> _ensureLikertZeroAllowed() async {
    final rows = await customSelect('''
      SELECT sql
      FROM sqlite_master
      WHERE type = 'table' AND name = 'avaliacao_item'
    ''').get();

    if (rows.isEmpty) return;

    final sql = rows.first.data['sql']?.toString() ?? '';
    if (sql.contains('BETWEEN 1 AND 5')) {
      await _rebuildAvaliacaoItemTableAllowingZeroLikert();
    }
  }

  Future<void> _repairLegacyDateColumns() async {
    final tableExists = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'avaliacao' LIMIT 1",
    ).get();

    if (tableExists.isEmpty) return;

    await customStatement('''
      UPDATE avaliacao
      SET
        data = CAST(strftime('%s', data) AS INTEGER) * 1000,
        data_alteracao = CAST(strftime('%s', data_alteracao) AS INTEGER) * 1000
      WHERE typeof(data) = 'text' OR typeof(data_alteracao) = 'text';
    ''');
  }

  static Future<void> repairLegacyDateColumns(QueryExecutor db) async {
    final tableExists = await db.runSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'avaliacao' LIMIT 1",
      [],
    );

    if (tableExists.isEmpty) return;

    await db.runCustom('''
      UPDATE avaliacao
      SET
        data = CAST(strftime('%s', data) AS INTEGER) * 1000,
        data_alteracao = CAST(strftime('%s', data_alteracao) AS INTEGER) * 1000
      WHERE typeof(data) = 'text' OR typeof(data_alteracao) = 'text';
    ''');
  }

  static AppDatabase? _instance;

  static Future<AppDatabase> instance() async {
    if (_instance != null) return _instance!;
    final executor = await _openConnection();
    _instance = AppDatabase._internal(executor);
    return _instance!;
  }

  static Future<void> resetInstance() async {
    if (_instance != null) {
      await _instance!.close();
      _instance = null;
    }
  }

  @override
  int get schemaVersion => 2;

  /// We override [migration] so we can insert seed data when the database is
  /// first created. This ensures every install starts with the same base
  /// information; the values can also be modified directly with SQL later.
  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) async {
        await m.createAll();

        // Seed default communities and categories. Add more entries here as needed.
        await into(comunidade)
            .insert(ComunidadeCompanion.insert(nome: 'Norte'));
        await into(comunidade).insert(ComunidadeCompanion.insert(nome: 'Sul'));
        await into(comunidade)
            .insert(ComunidadeCompanion.insert(nome: 'Leste'));
        await into(comunidade)
            .insert(ComunidadeCompanion.insert(nome: 'Oeste'));

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
          descricaoNivel1:
              Value('Alto gasto de energia, com consequente menor eficiência.'),
          descricaoNivel5: Value(
              'Baixo gasto de energia, com consequente eficiência energética.'),
          peso: Value(1.0),
          categoriaId: 1,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Escala',
          descricao:
              'Área de produção e prevalência de monocultura versus parcelas pequenas e diversificadas',
          descricaoNivel1: Value(
            'Práticas com alto impacto ambiental que demandam grandes áreas de produção.',
          ),
          descricaoNivel5: Value(
            'Práticas com baixo impacto ambiental que demandam pequenas áreas de produção.',
          ),
          peso: Value(0.5),
          categoriaId: 1,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Autossuficiência / Dependência de insumos',
          descricao:
              'Proporção de insumos externos (adubos químicos, agrotóxicos, sementes comerciais) versus insumos locais',
          descricaoNivel1: Value(
            'Baixa provisão de serviços ecossistêmicos e alta dependência de produtos e matérias-primas externos utilizados intensamente (adubos químicos sintéticos, agrotóxicos e sementes híbridas ou transgênicas) e irrigação convencional (aspersão com alta pressão).',
          ),
          descricaoNivel5: Value(
            'Alta provisão de serviços ecossistêmicos (regulação do clima, conservação do solo e da água, estoque de carbono e biodiversidade; ex.: polinizadores, inimigos naturais de fitopredadores, dispersão de sementes) e baixa dependência de produtos e matérias-primas externos que são muito pouco utilizados, tendo ênfase no manejo da matéria orgânica e estratégias que potencializem no solo a ciclagem de nutrientes e a fixação biológica do nitrogênio, bem como o uso de sementes próprias de variedades locais e o uso racional da água de irrigação (localizada, com baixa pressão).',
          ),
          peso: Value(0.8),
          categoriaId: 1,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Força de trabalho',
          descricao:
              'Predominância de mão de obra familiar versus contratação de terceiros',
          descricaoNivel1: Value(
            'Força de trabalho proveniente de mão de obra de terceiros.',
          ),
          descricaoNivel5: Value(
            'Força de trabalho proveniente da família.',
          ),
          peso: Value(0.8),
          categoriaId: 1,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Multifuncionalidade do trabalho',
          descricao:
              'Diversificação das atividades, presença de autoconsumo e serviços locais',
          descricaoNivel1: Value(
            'Elevado grau de especialização de atividades do trabalho da mão de obra utilizada. E, baixa presença de itens de autoconsumo e alta predominância de comercialização através de intermediários.',
          ),
          descricaoNivel5: Value(
            'Elevado grau de diversificação de atividades do trabalho da mão de obra utilizada. E, forte presença de itens de autoconsumo e estratégias de comercialização diversificadas, predominantemente voltadas para o mercado local.',
          ),
          peso: Value(0.9),
          categoriaId: 1,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Produtividade ecológica / Grau de artificialização',
          descricao:
              'Presença de elementos naturais, matéria orgânica do solo e práticas agroecológicas',
          descricaoNivel1: Value(
            'Ambiente altamente artificializado e com baixa diversidade natural.',
          ),
          descricaoNivel5: Value(
            'Ambiente com baixa artificialização e com alta diversidade natural.',
          ),
          peso: Value(0.7),
          categoriaId: 1,
        ));

        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Agrobiodiversidade',
          descricao:
              'Diversidade de espécies/variedades e uso de sementes locais versus híbridas/transgênicas',
          descricaoNivel1: Value(
            'Sistema agrícola com baixa diversidade de espécies, com uso de materiais genéticos híbridos e transgênicos. Uso de práticas convencionais, em sistemas de manejo simplificados (monocultura).',
          ),
          descricaoNivel5: Value(
            'Sistema agrícola com alta diversidade de espécies, variedades e raças. Uso de práticas agroecológicas, em sistemas de manejo complexos. ',
          ),
          peso: Value(0.8),
          categoriaId: 1,
        ));

        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Conhecimento',
          descricao:
              'Predominância de saberes tradicionais adaptados localmente versus pacotes tecnológicos',
          descricaoNivel1: Value(
            'Informação segmentada e simplificada obtida na forma de pacotes tecnológicos.',
          ),
          descricaoNivel5: Value(
            'Conhecimento tradicional multifacetado (holístico) e adaptado localmente mediante integração de saberes e acumulado por gerações.',
          ),
          peso: Value(0.9),
          categoriaId: 1,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Cosmovisão',
          descricao:
              'Visão de mundo: antropocêntrica/pragmática versus harmônica/integrada',
          descricaoNivel1: Value(
            'Percepção pragmática, objetiva, habitual e reducionista da realidade (antropocêntrica).',
          ),
          descricaoNivel5: Value(
            'Percepção abstrata, subjetiva, inabitual e profunda da realidade (harmônica).',
          ),
          peso: Value(0.6),
          categoriaId: 1,
        ));

        // --- data specific to the "Análise Multidimensional" category ---
        // Find the id by name so the seed stays robust.
        final cat2 = await (select(categoria)
              ..where((c) => c.nome.equals(
                  'Análise Multidimensional da Sustentabilidade das Práticas Agrícolas')))
            .getSingle();

        // dimensions
        final ecolDim = await into(dimensao).insertReturning(
            DimensaoCompanion.insert(nome: 'Ecológica', categoriaId: cat2.id));
        final socDim = await into(dimensao).insertReturning(
            DimensaoCompanion.insert(nome: 'Social', categoriaId: cat2.id));
        final econDim = await into(dimensao).insertReturning(
            DimensaoCompanion.insert(nome: 'Econômica', categoriaId: cat2.id));

        // aspects / indicador por dimensão
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Condições do solo',
          descricao:
              'Conservação ou melhoria das condições químicas, físicas e biológicas do solo',
          peso: Value(1.0),
          categoriaId: cat2.id,
          dimensaoId: Value(ecolDim.id),
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Recursos hídricos',
          descricao:
              'Manutenção ou melhoria da agrobiodiversidade e dos recursos hídricos',
          peso: Value(1.0),
          categoriaId: cat2.id,
          dimensaoId: Value(ecolDim.id),
        ));

        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Eliminação de insumos tóxicos',
          descricao:
              'Melhoria da qualidade de vida pela eliminação do uso de insumos tóxicos',
          peso: Value(1.0),
          categoriaId: cat2.id,
          dimensaoId: Value(socDim.id),
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Condições de trabalho',
          descricao:
              'Melhoria da qualidade de vida pelo menor uso de mão de obra e redução da penosidade do trabalho devido a melhor ergonomia',
          peso: Value(1.0),
          categoriaId: cat2.id,
          dimensaoId: Value(socDim.id),
        ));

        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Energias renováveis',
          descricao: 'Baixo consumo de energias não renováveis',
          peso: Value(1.0),
          categoriaId: cat2.id,
          dimensaoId: Value(econDim.id),
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Geração de renda',
          descricao:
              'Geração de renda com menor dependência de insumos externos',
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
          descricaoNivel1: Value('Dependente de interesses individuais.'),
          descricaoNivel5: Value(
            'Participação consciente e ativa nas atividades de interesse comum da organização, contribuindo em discussões, planejamento de eventos, elaboração de propostas, desenvolvimento e implantação de projetos.',
          ),
          peso: Value(1.0),
          categoriaId: cat3.id,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Representatividade',
          descricao:
              'Diversidade de opinião, raça, crença, nível educacional, cultura, gênero e geração entre os membros.',
          descricaoNivel1: Value(
            'Pouco diversa, composta por pessoas do mesmo grupo social.',
          ),
          descricaoNivel5: Value(
            'Incentiva a diversidade de opiniões, raça, crença, escolaridade, cultura, gênero e geração.',
          ),
          peso: Value(0.9),
          categoriaId: cat3.id,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Representação',
          descricao:
              'Forma como o presidente representa a organização e envolve os demais membros, delegando funções com a criação de comissões específicas e permanentes.',
          descricaoNivel1: Value(
            'O presidente representa sozinho a organização em todas as situações, sem envolver os demais membros.',
          ),
          descricaoNivel5: Value(
            'O presidente representa a organização em eventos sociais e políticos, mas promove a solução coletiva dos problemas e delega funções por meio de comissões permanentes.',
          ),
          peso: Value(0.6),
          categoriaId: cat3.id,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Planejamento e gestão',
          descricao:
              'Elaboração de diagnósticos, planejamento de ações e projetos a partir de planos de curto, médio e longo prazo com monitoramento e avaliação.',
          descricaoNivel1: Value(
            'Não realiza diagnósticos, planejamento de ações ou elaboração de projetos.',
          ),
          descricaoNivel5: Value(
            'As comissões planejam ações e projetos com base em diagnósticos e planos de curto, médio e longo prazo, acompanhando e avaliando seus resultados.',
          ),
          peso: Value(0.8),
          categoriaId: cat3.id,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Transparência',
          descricao:
              'Disponibilidade de atas, prestações de contas e documentos ao público. Exposição de planejamento e resultados em painéis acessíveis.',
          descricaoNivel1: Value(
            'Não há transparência; atas e prestações de contas não são elaboradas ou não são acessíveis. Não existe sistema de arquivamento de documentos.',
          ),
          descricaoNivel5: Value(
            'A missão da organização, atas, prestações de contas e demais documentos ficam disponíveis aos membros. O planejamento e os resultados são divulgados, e os documentos são organizados e digitalizados.',
          ),
          peso: Value(0.9),
          categoriaId: cat3.id,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Decisão',
          descricao:
              'Tomada de decisão através de processos dialógicos e democráticos visando consenso, com métodos como circularidade da fala e escuta ativa.',
          descricaoNivel1: Value(
            'Decisões centralizadas na presidência ou diretoria.',
          ),
          descricaoNivel5: Value(
            'As decisões são tomadas por processos dialógicos e democráticos, buscando consenso, com participação de todos e regras de convivência definidas.',
          ),
          peso: Value(0.8),
          categoriaId: cat3.id,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Disposição dos participantes nas reuniões',
          descricao:
              'Arranjo físico das reuniões em círculo sem lugar de destaque, onde todos ensinam e aprendem caracterizando a singularidade dos saberes.',
          descricaoNivel1: Value(
            'Participantes organizados em fileiras, com separação entre quem conduz e quem participa.',
          ),
          descricaoNivel5: Value(
            'Participantes organizados em círculo, sem posições de destaque, promovendo a troca de conhecimentos entre todos.',
          ),
          peso: Value(0.5),
          categoriaId: cat3.id,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Temas relevantes',
          descricao:
              'Abordagem de temas prioritários hierarquizados para discussão em comissões permanentes. Capacitação técnica e política em diversos temas.',
          descricaoNivel1: Value(
            'Discussão limitada aos mesmos temas de interesse geral ou individual, sem evolução para assuntos estratégicos.',
          ),
          descricaoNivel5: Value(
            'As reuniões abordam temas prioritários e promovem capacitações em áreas como agroecologia, meio ambiente, cidadania, gestão social, políticas públicas, empreendedorismo rural e economia solidária.',
          ),
          peso: Value(0.8),
          categoriaId: cat3.id,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Formação',
          descricao:
              'Promoção de oficinas, palestras temáticas e atividades de formação continuada para capacitação dos associados.',
          descricaoNivel1: Value(
            'Não promove palestras, oficinas ou capacitações.',
          ),
          descricaoNivel5: Value(
            'Promove continuamente oficinas, palestras e atividades de formação, inclusive durante as reuniões ordinárias e conforme as demandas dos associados.',
          ),
          peso: Value(0.8),
          categoriaId: cat3.id,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Sucessão',
          descricao:
              'Renovação regular dos quadros da diretoria com eleições periódicas, evitando permanência indefinida do mesmo grupo.',
          descricaoNivel1: Value(
            'Não há renovação da diretoria, permanecendo o mesmo grupo por vários mandatos.',
          ),
          descricaoNivel5: Value(
            'Há renovação periódica da diretoria por meio de eleições, permitindo apenas uma reeleição quando os princípios da organização são atendidos.',
          ),
          peso: Value(0.7),
          categoriaId: cat3.id,
        ));
        await into(indicador).insert(IndicadorCompanion.insert(
          nome: 'Empoderamento',
          descricao:
              'Ocupação de espaços de representação em conselhos, comitês e fóruns regionais pela organização e seus representantes.',
          descricaoNivel1: Value(
            'Não ocupa espaços de decisão ou representação em conselhos, comitês e fóruns regionais.',
          ),
          descricaoNivel5: Value(
            'Os representantes participam ativamente de conselhos, comitês e fóruns regionais, fortalecendo o processo de empoderamento da organização.',
          ),
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
          peso: Value(0.1),
          categoriaId: cat4.id,
        ));
      }, onUpgrade: (m, from, to) async {
        if (from < 2) {
          await _rebuildAvaliacaoItemTableAllowingZeroLikert();
        }
      }, beforeOpen: (details) async {
        await _ensureLikertZeroAllowed();
        await _repairLegacyDateColumns();
      });
}

Future<QueryExecutor> _openConnection() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'db.sqlite'));
  print(file.path);
  return NativeDatabase(file);
}

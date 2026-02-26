import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/regioes_table.dart';
import 'tables/familias_table.dart';
import 'tables/categorias_table.dart';
import 'tables/indicadores_table.dart';
import 'tables/avaliacoes_table.dart';
import 'tables/avaliacao_itens_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Regioes,
    Familias,
    Categorias,
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
  int get schemaVersion => 1;

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

          await into(categorias).insert(CategoriasCompanion.insert(
              nome: 'Campesinidade',
              descricao: Value('modo de vida, valores e práticas camponesas')));
          await into(categorias).insert(CategoriasCompanion.insert(
              nome: 'Sustentabilidade',
              descricao: Value('ambiental, social e econômica')));
          await into(categorias).insert(CategoriasCompanion.insert(
              nome: 'Organização social',
              descricao: Value('associações, cooperativas, ação coletiva')));
          await into(categorias).insert(CategoriasCompanion.insert(
              nome: 'Agenciamento do desenvolvimento rural',
              descricao: Value(
                  'capacidade dos atores locais de conduzir seu próprio desenvolvimento')));

          // Optionally insert some indicators as examples
          await into(indicadores).insert(IndicadoresCompanion.insert(
            nome: 'Consumo de água',
            descricao: 'Litragem diária',
            peso: Value(1.0),
            categoriaId: 1,
          ));
        },
      );
}

Future<QueryExecutor> _openConnection() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'db.sqlite'));
  return NativeDatabase(file);
}

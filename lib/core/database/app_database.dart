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
}

Future<QueryExecutor> _openConnection() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'db.sqlite'));
  return NativeDatabase(file);
}

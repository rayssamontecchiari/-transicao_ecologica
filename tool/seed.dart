import 'package:drift/drift.dart';
import 'package:transicao_ecologica/core/database/app_database.dart';

/// Run this script with `dart run tool/seed.dart` to manually populate the
/// database with default values. Useful when you already have a database and
/// want to re-seed or when running on a CI without rebuilding the schema.

Future<void> main() async {
  final db = await AppDatabase.instance();

  // Check existing regions and categories first so we don't duplicate entries.
  final regioes = await db.select(db.regiao).get();
  if (regioes.isEmpty) {
    await db.into(db.regiao).insert(RegiaoCompanion.insert(nome: 'Norte'));
    await db.into(db.regiao).insert(RegiaoCompanion.insert(nome: 'Sul'));
    await db.into(db.regiao).insert(RegiaoCompanion.insert(nome: 'Leste'));
    await db.into(db.regiao).insert(RegiaoCompanion.insert(nome: 'Oeste'));
    print('Regiões seed inseridas.');
  } else {
    print('Regiões já existem, pulando.');
  }

  final categorias = await db.select(db.categoria).get();
  if (categorias.isEmpty) {
    await db.into(db.categoria).insert(CategoriaCompanion.insert(
        nome: 'Campesinidade',
        descricao: Value('modo de vida, valores e práticas camponesas')));
    await db.into(db.categoria).insert(CategoriaCompanion.insert(
        nome: 'Sustentabilidade',
        descricao: Value('ambiental, social e econômica')));
    await db.into(db.categoria).insert(CategoriaCompanion.insert(
        nome: 'Organização social',
        descricao: Value('associações, cooperativas, ação coletiva')));
    await db.into(db.categoria).insert(CategoriaCompanion.insert(
        nome: 'Agenciamento do desenvolvimento rural',
        descricao: Value(
            'capacidade dos atores locais de conduzir seu próprio desenvolvimento')));
    print('Categorias seed inseridas.');
  } else {
    print('Categorias já existem, pulando.');
  }

  print('Seed concluído.');
  await db.close();
}

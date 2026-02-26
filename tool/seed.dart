import 'package:drift/drift.dart';
import 'package:transicao_ecologica/core/database/app_database.dart';

/// Run this script with `dart run tool/seed.dart` to manually populate the
/// database with default values. Useful when you already have a database and
/// want to re-seed or when running on a CI without rebuilding the schema.

Future<void> main() async {
  final db = await AppDatabase.instance();

  // Check existing regions and categories first so we don't duplicate entries.
  final regioes = await db.select(db.regioes).get();
  if (regioes.isEmpty) {
    await db.into(db.regioes).insert(RegioesCompanion.insert(nome: 'Norte'));
    await db.into(db.regioes).insert(RegioesCompanion.insert(nome: 'Sul'));
    await db.into(db.regioes).insert(RegioesCompanion.insert(nome: 'Leste'));
    await db.into(db.regioes).insert(RegioesCompanion.insert(nome: 'Oeste'));
    print('Regiões seed inseridas.');
  } else {
    print('Regiões já existem, pulando.');
  }

  final categorias = await db.select(db.categorias).get();
  if (categorias.isEmpty) {
    await db.into(db.categorias).insert(CategoriasCompanion.insert(
        nome: 'Campesinidade',
        descricao: Value('modo de vida, valores e práticas camponesas')));
    await db.into(db.categorias).insert(CategoriasCompanion.insert(
        nome: 'Sustentabilidade',
        descricao: Value('ambiental, social e econômica')));
    await db.into(db.categorias).insert(CategoriasCompanion.insert(
        nome: 'Organização social',
        descricao: Value('associações, cooperativas, ação coletiva')));
    await db.into(db.categorias).insert(CategoriasCompanion.insert(
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

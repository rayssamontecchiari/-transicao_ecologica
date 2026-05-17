import 'package:drift/drift.dart';

@DataClassName('CategoriaData')
class Categoria extends Table {
  @override
  String get tableName => 'categoria';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
  TextColumn get descricao => text().nullable()();
}

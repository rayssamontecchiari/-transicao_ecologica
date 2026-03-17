import 'package:drift/drift.dart';

@DataClassName('Categoria')
class Categorias extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
  TextColumn get descricao => text().nullable()();
}

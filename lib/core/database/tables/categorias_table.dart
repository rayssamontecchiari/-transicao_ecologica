import 'package:drift/drift.dart';

class Categorias extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
  TextColumn get descricao => text().nullable()();
}

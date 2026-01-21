import 'package:drift/drift.dart';
import 'regioes_table.dart';

class Familias extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nomeResponsavel => text()();
  TextColumn get telefone => text()();
  TextColumn get endereco => text()();

  IntColumn get regiaoId => integer().references(Regioes, #id)();
}

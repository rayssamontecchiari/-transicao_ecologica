import 'package:drift/drift.dart';
import 'regiao_table.dart';

@DataClassName('FamiliaData')
class Familia extends Table {
  @override
  String get tableName => 'familia';
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nomeResponsavel => text()();
  TextColumn get telefone => text()();
  TextColumn get endereco => text()();

  IntColumn get regiaoId => integer().references(Regiao, #id)();
}

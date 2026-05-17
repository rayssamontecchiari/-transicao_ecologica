import 'package:drift/drift.dart';
import 'familia_table.dart';

@DataClassName('AvaliacaoData')
class Avaliacao extends Table {
  @override
  String get tableName => 'avaliacao';
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get data => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get dataAlteracao =>
      dateTime().withDefault(currentDateAndTime)();

  TextColumn get avaliador => text()();
  TextColumn get observacoes => text().nullable()();

  /// 'draft' = em progresso, 'completed' = finalizada
  TextColumn get status => text().withDefault(const Constant('draft'))();

  /// Qual categoria o usuário está preenchendo (0-3)
  IntColumn get familiaId => integer().references(Familia, #id)();
}

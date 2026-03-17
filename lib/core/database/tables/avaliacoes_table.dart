import 'package:drift/drift.dart';
import 'familias_table.dart';

@DataClassName('Avaliacao')
class Avaliacoes extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get data => dateTime().withDefault(currentDateAndTime)();

  TextColumn get avaliador => text()();
  TextColumn get observacoes => text().nullable()();

  IntColumn get familiaId => integer().references(Familias, #id)();
}

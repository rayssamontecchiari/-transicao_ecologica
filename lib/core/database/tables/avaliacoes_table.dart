import 'package:drift/drift.dart';
import 'familias_table.dart';

@DataClassName('Avaliacao')
class Avaliacoes extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get data => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get dataAlteracao =>
      dateTime().withDefault(currentDateAndTime)();

  TextColumn get avaliador => text()();
  TextColumn get observacoes => text().nullable()();

  /// 'draft' = em progresso, 'completed' = finalizada
  TextColumn get status => text().withDefault(const Constant('draft'))();

  /// Qual categoria o usuário está preenchendo (0-3)
  IntColumn get categoriaAtual => integer().withDefault(const Constant(0))();

  IntColumn get familiaId => integer().references(Familias, #id)();
}

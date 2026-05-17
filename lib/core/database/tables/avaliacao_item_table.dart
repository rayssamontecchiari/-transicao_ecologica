import 'package:drift/drift.dart';
import 'avaliacao_table.dart';
import 'indicador_table.dart';
import 'pratica_table.dart';

@DataClassName('AvaliacaoItemData')
class AvaliacaoItem extends Table {
  @override
  String get tableName => 'avaliacao_item';
  IntColumn get id => integer().autoIncrement()();

  IntColumn get avaliacaoId => integer().references(Avaliacao, #id)();

  IntColumn get indicadorId => integer().references(Indicador, #id)();

  /// When evaluating the special "Multidimensional" category, an item is
  /// tied to a particular agricultural practice. For other categories this
  /// column remains null.
  IntColumn get praticaId => integer().nullable().references(Pratica, #id)();

  IntColumn get valorLikert => integer()
      .nullable()
      .customConstraint('CHECK (valor_likert BETWEEN 1 AND 5)')();

  RealColumn get valorFuzzy => real().nullable()();
}

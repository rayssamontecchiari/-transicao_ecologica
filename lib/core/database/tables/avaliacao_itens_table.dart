import 'package:drift/drift.dart';
import 'avaliacoes_table.dart';
import 'indicadores_table.dart';
import 'praticas_table.dart';

@DataClassName('AvaliacaoItem')
class AvaliacaoItens extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get avaliacaoId => integer().references(Avaliacoes, #id)();

  IntColumn get indicadorId => integer().references(Indicadores, #id)();

  /// When evaluating the special "Multidimensional" category, an item is
  /// tied to a particular agricultural practice. For other categories this
  /// column remains null.
  IntColumn get praticaId => integer().nullable().references(Praticas, #id)();

  IntColumn get valorLikert => integer()
      .nullable()
      .customConstraint('CHECK (valor_likert BETWEEN 1 AND 5)')();

  RealColumn get valorFuzzy => real().nullable()();
}

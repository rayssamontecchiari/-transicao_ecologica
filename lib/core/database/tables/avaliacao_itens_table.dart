import 'package:drift/drift.dart';
import 'avaliacoes_table.dart';
import 'indicadores_table.dart';

class AvaliacaoItens extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get avaliacaoId => integer().references(Avaliacoes, #id)();

  IntColumn get indicadorId => integer().references(Indicadores, #id)();

  IntColumn get valorLikert => integer()
      .nullable()
      .customConstraint('CHECK (valor_likert BETWEEN 1 AND 5)')();

  RealColumn get valorFuzzy => real().nullable()();
}

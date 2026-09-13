import 'package:flutter_test/flutter_test.dart';
import 'package:transicao_ecologica/core/services/fuzzy_calculator.dart';

void main() {
  group('FuzzyCalculator', () {
    test('calcula valores fuzzy conforme tabela para nota unica', () {
      final nota5 = FuzzyCalculator.calcularPorNotas([5], [1.0]);
      expect(nota5['d'], closeTo(0.7, 1e-12));
      expect(nota5['a'], closeTo(0.9, 1e-12));
      expect(nota5['b'], closeTo(1.0, 1e-12));
      expect(nota5['c'], closeTo(1.0, 1e-12));
      expect(nota5['centroide'], closeTo(0.9, 1e-12));
      expect(nota5['resultado'], closeTo(1.0, 1e-12));

      final nota1 = FuzzyCalculator.calcularPorNotas([1], [1.0]);
      expect(nota1['d'], closeTo(0.0, 1e-12));
      expect(nota1['a'], closeTo(0.0, 1e-12));
      expect(nota1['b'], closeTo(0.1, 1e-12));
      expect(nota1['c'], closeTo(0.3, 1e-12));
      expect(nota1['centroide'], closeTo(0.1, 1e-12));
      expect(nota1['resultado'], closeTo(0.0, 1e-12));

      final nota0 = FuzzyCalculator.calcularPorNotas([0], [1.0]);
      expect(nota0['d'], closeTo(0.0, 1e-12));
      expect(nota0['a'], closeTo(0.0, 1e-12));
      expect(nota0['b'], closeTo(0.0, 1e-12));
      expect(nota0['c'], closeTo(0.0, 1e-12));
      expect(nota0['centroide'], closeTo(0.0, 1e-12));
      expect(nota0['resultado'], closeTo(0.0, 1e-12));
    });

    test('calcula F1 com media ponderada pela soma dos pesos', () {
      final notas = [3, 4, 1, 2, 1, 5, 2, 2, 3];
      final pesos = [1.0, 0.5, 0.8, 0.8, 0.9, 0.7, 0.8, 0.9, 0.6];

      final result = FuzzyCalculator.calcularPorNotas(notas, pesos);

      expect(result['d'], closeTo(0.21, 1e-12));
      expect(result['a'], closeTo(0.3614285714285714, 1e-12));
      expect(result['b'], closeTo(0.3957142857142857, 1e-12));
      expect(result['c'], closeTo(0.5757142857142856, 1e-12));
      expect(result['base'], closeTo(0.36571428571428566, 1e-12));
      expect(result['centroide'], closeTo(0.3857142857142857, 1e-12));
      expect(result['resultado'], closeTo(0.3571428571428571, 1e-12));
    });

    test('pesos alteram o resultado final', () {
      final notas = [3, 4, 1, 2, 1, 5, 2, 2, 3];
      final resultComPesos = FuzzyCalculator.calcularPorNotas(
        notas,
        [1.0, 0.5, 0.8, 0.8, 0.9, 0.7, 0.8, 0.9, 0.6],
      );
      final resultPesosUnitarios = FuzzyCalculator.calcularPorNotas(
          notas, List.filled(notas.length, 1.0));

      expect(resultComPesos['resultado'],
          isNot(resultPesosUnitarios['resultado']));
    });

    test('lanca erro quando listas de notas e pesos tem tamanhos diferentes',
        () {
      expect(
        () => FuzzyCalculator.calcularPorNotas([1, 2], [1.0]),
        throwsArgumentError,
      );
    });
  });
}

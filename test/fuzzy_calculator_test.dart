import 'package:flutter_test/flutter_test.dart';
import 'package:transicao_ecologica/core/models/resultado_avaliacao.dart';
import 'package:transicao_ecologica/core/services/fuzzy_calculator.dart';
import 'package:transicao_ecologica/core/services/resultado_avaliacao_service.dart';

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

    test('calcula o exemplo da planilha com arredondamento para 2 casas', () {
      final notas = [3, 4, 1, 2, 1, 5, 2, 2, 3];
      final pesos = [1.0, 0.5, 0.8, 0.8, 0.9, 0.7, 0.8, 0.9, 0.6];

      final result = FuzzyCalculator.calcularPorNotas(notas, pesos);

      expect(result['d'], closeTo(0.21, 1e-12));
      expect(result['a'], closeTo(0.36, 1e-12));
      expect(result['b'], closeTo(0.4, 1e-12));
      expect(result['c'], closeTo(0.58, 1e-12));
      expect(result['base'], closeTo(0.37, 1e-12));
      expect(result['centroide'], closeTo(0.39, 1e-12));
      expect(result['resultado'], closeTo(0.36, 1e-12));
    });

    test('arredonda o cálculo antes de salvar o resultado final', () {
      final notas = [3, 4, 1, 2, 1, 5, 2, 2, 3];
      final pesos = [1.0, 0.5, 0.8, 0.8, 0.9, 0.7, 0.8, 0.9, 0.6];

      final fuzzyResult = FuzzyCalculator.calcularPorNotas(notas, pesos);

      expect(fuzzyResult['resultado'], closeTo(0.36, 1e-12));

      final salvo = ResultadoAvaliacao.fromCalculation(
        avaliacaoId: 1,
        categoriaId: 2,
        fuzzyResult: fuzzyResult,
      );

      expect(salvo.valorFuzzyFinal, closeTo(0.36, 1e-12));
    });

    test('conforme a planilha, usa a tabela exata e a média ponderada', () {
      final notas = [3, 3, 5, 3, 5, 4, 1, 4, 1, 5, 3];
      final pesos = [1.0, 0.9, 0.6, 0.8, 0.9, 0.8, 0.5, 0.8, 0.8, 0.7, 0.7];

      final result = FuzzyCalculator.calcularPorNotas(notas, pesos);

      expect(result['d'], closeTo(0.4, 1e-12));
      expect(result['a'], closeTo(0.56, 1e-12));
      expect(result['b'], closeTo(0.61, 1e-12));
      expect(result['c'], closeTo(0.75, 1e-12));
      expect(result['centroide'], closeTo(0.58, 1e-12));
      expect(result['base'], closeTo(0.36, 1e-12));
      expect(result['resultado'], closeTo(0.6, 1e-12));
    });

    test('calcula nota da prática por percentual de aspectos selecionados', () {
      expect(
        ResultadoAvaliacaoService.calcularNotaPratica(
          marcacoes: 0,
          totalAspectos: 6,
        ),
        0,
      );
      expect(
        ResultadoAvaliacaoService.calcularNotaPratica(
          marcacoes: 2,
          totalAspectos: 6,
        ),
        2,
      );
      expect(
        ResultadoAvaliacaoService.calcularNotaPratica(
          marcacoes: 3,
          totalAspectos: 6,
        ),
        3,
      );
      expect(
        ResultadoAvaliacaoService.calcularNotaPratica(
          marcacoes: 6,
          totalAspectos: 6,
        ),
        5,
      );
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

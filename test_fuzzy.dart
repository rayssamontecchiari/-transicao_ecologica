import 'package:transicao_ecologica/core/services/fuzzy_calculator.dart';

void main() {
  // Primeiro exemplo: notas 3,4,1,2,1,5,2,2,3
  // pesos 1.0,0.5,0.8,0.8,0.9,0.7,0.8,0.9,0.6
  List<int> notas1 = [3, 4, 1, 2, 1, 5, 2, 2, 3];
  List<double> pesos1 = [1.0, 0.5, 0.8, 0.8, 0.9, 0.7, 0.8, 0.9, 0.6];

  var result1 = FuzzyCalculator.calcularPorNotas(notas1, pesos1);

  print('Primeiro exemplo:');
  print('d: ${result1['d']}');
  print('a: ${result1['a']}');
  print('b: ${result1['b']}');
  print('c: ${result1['c']}');
  print('centróide: ${result1['centroide']}');
  print('base: ${result1['base']}');
  print('resultado: ${result1['resultado']}');

  // Segundo exemplo: notas 5,5,3,4,5,4,5,5,3,4,3
  // pesos 1,0.9,0.6,0.8,0.9,0.8,0.5,0.8,0.8,0.7,0.7
  List<int> notas2 = [5, 5, 3, 4, 5, 4, 5, 5, 3, 4, 3];
  List<double> pesos2 = [1.0, 0.9, 0.6, 0.8, 0.9, 0.8, 0.5, 0.8, 0.8, 0.7, 0.7];

  var result2 = FuzzyCalculator.calcularPorNotas(notas2, pesos2);

  print('\nSegundo exemplo:');
  print('d: ${result2['d']}');
  print('a: ${result2['a']}');
  print('b: ${result2['b']}');
  print('c: ${result2['c']}');
  print('centróide: ${result2['centroide']}');
  print('base: ${result2['base']}');
  print('resultado: ${result2['resultado']}');

  // Terceiro exemplo: notas 3,4,1,2,1,5,2,2
  // pesos 1,1,1,1,1,1,1,1
  List<int> notas3 = [3, 4, 1, 2, 1, 5, 2, 2];
  List<double> pesos3 = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0];

  var result3 = FuzzyCalculator.calcularPorNotas(notas3, pesos3);

  print('\nTerceiro exemplo:');
  print('d: ${result3['d']}');
  print('a: ${result3['a']}');
  print('b: ${result3['b']}');
  print('c: ${result3['c']}');
  print('centróide: ${result3['centroide']}');
  print('base: ${result3['base']}');
  print('resultado: ${result3['resultado']}');

  // Quarto exemplo: notas 0,4,3,0,0
  // pesos 1,0.7,0.6,0.4,0.11
  List<int> notas4 = [0, 4, 3, 0, 0];
  List<double> pesos4 = [1.0, 0.7, 0.6, 0.4, 0.11];

  var result4 = FuzzyCalculator.calcularPorNotas(notas4, pesos4);

  print('\nQuarto exemplo:');
  print('d: ${result4['d']}');
  print('a: ${result4['a']}');
  print('b: ${result4['b']}');
  print('c: ${result4['c']}');
  print('centróide: ${result4['centroide']}');
  print('base: ${result4['base']}');
  print('resultado: ${result4['resultado']}');

  // Quinto exemplo: notas 5,5,1,2,3,5,2,3,3
  // pesos 1,0.5,0.8,0.8,0.9,0.7,0.8,0.9,0.6
  List<int> notas5 = [5, 5, 1, 2, 3, 5, 2, 3, 3];
  List<double> pesos5 = [1.0, 0.5, 0.8, 0.8, 0.9, 0.7, 0.8, 0.9, 0.6];

  var result5 = FuzzyCalculator.calcularPorNotas(notas5, pesos5);

  print('\nQuinto exemplo:');
  print('d: ${result5['d']}');
  print('a: ${result5['a']}');
  print('b: ${result5['b']}');
  print('c: ${result5['c']}');
  print('centróide: ${result5['centroide']}');
  print('base: ${result5['base']}');
  print('resultado: ${result5['resultado']}');
}

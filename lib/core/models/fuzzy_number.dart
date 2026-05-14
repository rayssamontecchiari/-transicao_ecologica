class FuzzyNumber {
  final int nota;
  final double peso;

  FuzzyNumber({
    required this.nota,
    this.peso = 1,
  });

  Map<String, double> calcular() {
    double somaA = 0, somaB = 0, somaC = 0, somaD = 0;
    double totalPeso = 0;

    totalPeso += peso;

    somaA += _valorA(nota) / 10 * peso;
    somaB += _valorB(nota) / 10 * peso;
    somaC += _valorC(nota) / 10 * peso;
    somaD += _valorD(nota) / 10 * peso;

    double centroide = (somaA + somaB + somaC + somaD) / (4 * totalPeso);
    double base = (somaC - somaD) / totalPeso;

    double resultado =
        centroide < 0.1 ? centroide : (centroide - 0.1) / (0.9 - 0.1);

    return {
      'a': somaA / totalPeso,
      'b': somaB / totalPeso,
      'c': somaC / totalPeso,
      'd': somaD / totalPeso,
      'centroide': centroide,
      'base': base,
      'resultado': resultado,
    };
  }

  double _valorA(int g) =>
      {5: 6.623, 4: 7.0729, 3: 3.593, 2: 3.0, 1: 0.0, 0: 0.0}[g] ?? 0.0;
  double _valorB(int g) =>
      {5: 7.361, 4: 7.0729, 3: 3.580, 2: 3.0, 1: 1.0, 0: 0.0}[g] ?? 0.0;
  double _valorC(int g) =>
      {5: 8.504, 4: 9.0565, 3: 5.869, 2: 5.0, 1: 3.0, 0: 0.0}[g] ?? 0.0;
  double _valorD(int g) =>
      {5: 4.765, 4: 5.0703, 3: 1.969, 2: 1.0, 1: 0.0, 0: 0.0}[g] ?? 0.0;
}

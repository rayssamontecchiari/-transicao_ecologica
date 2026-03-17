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

  int _valorA(int g) => {5: 9, 4: 7, 3: 5, 2: 3, 1: 0, 0: 0}[g] ?? 0;
  int _valorB(int g) => {5: 10, 4: 7, 3: 5, 2: 3, 1: 1, 0: 0}[g] ?? 0;
  int _valorC(int g) => {5: 10, 4: 9, 3: 7, 2: 5, 1: 3, 0: 0}[g] ?? 0;
  int _valorD(int g) => {5: 7, 4: 5, 3: 3, 2: 1, 1: 0, 0: 0}[g] ?? 0;
}

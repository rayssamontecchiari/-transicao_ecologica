/// Representa um número fuzzy triangular com componentes (d, a, b, c)
/// onde d é o ponto esquerdo, a e b são o pico, e c é o ponto direito
class FuzzyNumber {
  final double d;
  final double a;
  final double b;
  final double c;

  FuzzyNumber({
    required this.d,
    required this.a,
    required this.b,
    required this.c,
  });

  Map<String, double> calcular(value) {
    double somaA = 0, somaB = 0, somaC = 0, somaD = 0;
    double totalPeso = 0;

    int g = value;
    double peso = value ?? 1;
    totalPeso += peso;

    somaA += _valorA(g) / 10 * peso;
    somaB += _valorB(g) / 10 * peso;
    somaC += _valorC(g) / 10 * peso;
    somaD += _valorD(g) / 10 * peso;

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

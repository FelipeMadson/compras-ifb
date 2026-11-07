import 'dart:math';

/// Representação semântica de falha temporária ou oscilação de conectividade.
class FalhaTransitoria implements Exception {
  const FalhaTransitoria(this.mensagem);

  final String mensagem;

  @override
  String toString() => 'FalhaTransitoria: $mensagem';
}

/// Executa [operacao] de forma resiliente mediante algoritmo de recuo exponencial com ruído aleatório (full jitter).
///
/// A fórmula calcula a espera base multiplicada por 2^(tentativa - 1),
/// acrescida de uma fração aleatória sorteada dentro do limite base para mitigar o
/// fenômeno de sobrecarga sincronizada de requisições concorrentes ("thundering herd problem").
Future<T> comNovaTentativa<T>(
  Future<T> Function() operacao, {
  int maxTentativas = 3,
  Duration esperaBase = const Duration(milliseconds: 500),
  Random? aleatorio,
}) async {
  final sorteio = aleatorio ?? Random();
  var tentativa = 0;

  while (true) {
    try {
      return await operacao();
    } on FalhaTransitoria {
      tentativa++;
      if (tentativa >= maxTentativas) {
        rethrow;
      }
      final exponencial = esperaBase * (1 << (tentativa - 1));
      final limiteDoJitter = esperaBase.inMilliseconds;
      final jitter = Duration(
        milliseconds: limiteDoJitter > 0 ? sorteio.nextInt(limiteDoJitter) : 0,
      );
      await Future<void>.delayed(exponencial + jitter);
    }
  }
}

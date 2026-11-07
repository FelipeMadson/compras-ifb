import 'package:compras/dados/remoto/nova_tentativa.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('repete execução mediante falhas transitórias até obter resposta satisfatória', () async {
    var chamadas = 0;
    final resultado = await comNovaTentativa(() async {
      chamadas++;
      if (chamadas < 3) throw const FalhaTransitoria('instabilidade de sinal');
      return 'sucesso';
    }, esperaBase: Duration.zero);

    expect(resultado, 'sucesso');
    expect(chamadas, 3);
  });

  test('interrompe e propaga exceção ao esgotar o teto máximo de tentativas', () async {
    var chamadas = 0;
    await expectLater(
      comNovaTentativa<void>(
        () async {
          chamadas++;
          throw const FalhaTransitoria('servidor indisponível');
        },
        maxTentativas: 2,
        esperaBase: Duration.zero,
      ),
      throwsA(isA<FalhaTransitoria>()),
    );
    expect(chamadas, 2);
  });
}

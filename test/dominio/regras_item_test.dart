import 'package:compras/dominio/item.dart';
import 'package:compras/dominio/regras_item.dart';
import 'package:flutter_test/flutter_test.dart';

Item _item(
  String nome,
  String categoria, {
  bool comprado = false,
  bool sincronizado = true,
}) {
  final data = DateTime(2026);
  return Item(
    nome: nome,
    categoria: categoria,
    comprado: comprado,
    sincronizado: sincronizado,
    criadoEm: data,
    atualizadoEm: data,
  );
}

void main() {
  group('Regra de Validação de Nome (validarNome)', () {
    test('recusa nome vazio ou preenchido exclusivamente por espaços', () {
      expect(validarNome('   '), isNotNull);
      expect(validarNome(''), isNotNull);
    });

    test('recusa nome com comprimento inferior a 2 caracteres úteis', () {
      expect(validarNome('a'), isNotNull);
    });

    test('recusa nome que exceda o limite máximo de 40 caracteres', () {
      expect(validarNome('x' * (tamanhoMaximoNome + 1)), isNotNull);
    });

    test('aceita nome perfeitamente válido ignorando espaços periféricos', () {
      expect(validarNome('  Café Arábica Especial  '), isNull);
    });
  });

  group('Regra de Ajuste de Quantidade (ajustarQuantidade)', () {
    test('soma e subtrai adequadamente dentro do intervalo válido', () {
      expect(ajustarQuantidade(3, 1), 4);
      expect(ajustarQuantidade(3, -1), 2);
    });

    test('impede transgressão dos limites inferior (1) e superior (99)', () {
      expect(ajustarQuantidade(quantidadeMinima, -1), quantidadeMinima);
      expect(ajustarQuantidade(quantidadeMaxima, 1), quantidadeMaxima);
    });
  });

  test('Ordena itens pendentes prioritariamente e subsequentemente por categoria e nome', () {
    final ordenados = ordenarParaExibicao([
      _item('Sabão em Pó', 'Limpeza', comprado: true),
      _item('Feijão Carioca', 'Mercearia'),
      _item('Alface Crespa', 'Hortifrúti'),
      _item('Arroz Integral', 'Mercearia'),
    ]);

    expect(ordenados.map((item) => item.nome).toList(), [
      'Alface Crespa',
      'Arroz Integral',
      'Feijão Carioca',
      'Sabão em Pó',
    ]);
  });

  test('Consolidação matemática de resumo (resumir)', () {
    final resumo = resumir([
      _item('A', 'Mercearia', comprado: true),
      _item('B', 'Hortifrúti', sincronizado: false),
      _item('C', 'Limpeza'),
    ]);

    expect(resumo.total, 3);
    expect(resumo.comprados, 1);
    expect(resumo.aguardandoEnvio, 1);
    expect(resumo.progresso, closeTo(1 / 3, 0.001));
    expect(resumo.concluido, isFalse);

    final concluido = resumir([
      _item('A', 'Mercearia', comprado: true),
      _item('B', 'Mercearia', comprado: true),
    ]);
    expect(concluido.concluido, isTrue);
  });
}

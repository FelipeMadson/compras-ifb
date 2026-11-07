import 'package:compras/dados/local/banco_de_dados.dart';
import 'package:compras/dados/local/item_repository_sqlite.dart';
import 'package:compras/dominio/item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late BancoDeDados banco;
  late ItemRepositorySqlite repositorio;

  setUpAll(sqfliteFfiInit);

  setUp(() {
    banco = BancoDeDados(
      fabrica: databaseFactoryFfi,
      caminho: inMemoryDatabasePath,
    );
    repositorio = ItemRepositorySqlite(banco);
  });

  tearDown(() => banco.fechar());

  Item novo(String nome) {
    final data = DateTime(2026, 3, 1);
    return Item(
      nome: nome,
      categoria: 'Mercearia',
      criadoEm: data,
      atualizadoEm: data,
    );
  }

  test('insere e recupera fidedignamente todos os atributos relacionais', () async {
    final salvo = await repositorio.salvar(
      novo('Café Gourmet').copyWith(quantidade: 2, observacao: 'Grãos moídos'),
    );
    expect(salvo.id, isNotNull);

    final lido = (await repositorio.listar()).single;
    expect(lido.id, salvo.id);
    expect(lido.nome, 'Café Gourmet');
    expect(lido.quantidade, 2);
    expect(lido.observacao, 'Grãos moídos');
    expect(lido.comprado, isFalse);
    expect(lido.sincronizado, isFalse);
  });

  test('atualiza registro preexistente sem introduzir duplicatas na tabela', () async {
    final salvo = await repositorio.salvar(novo('Leite Integral'));
    await repositorio.salvar(salvo.copyWith(comprado: true));

    final itens = await repositorio.listar();
    expect(itens, hasLength(1));
    expect(itens.single.comprado, isTrue);
  });

  test('remove registro pela chave primária (id)', () async {
    final salvo = await repositorio.salvar(novo('Pão Francês'));
    await repositorio.excluir(salvo.id!);
    expect(await repositorio.listar(), isEmpty);
  });

  test('marca registro como sincronizado após sucesso de envio', () async {
    await repositorio.salvar(novo('Sal Refinado'));
    final enviado = (await repositorio.listarNaoSincronizados()).single;
    await repositorio.marcarComoSincronizado(enviado);
    expect(await repositorio.listarNaoSincronizados(), isEmpty);
  });

  test('bloqueio otimista: não marca como sincronizada versão modificada durante o envio', () async {
    final salvo = await repositorio.salvar(novo('Ovos Orgânicos'));
    final enviado = (await repositorio.listarNaoSincronizados()).single;

    // Mutação concorrente ocorrida após leitura e antes da confirmação do servidor
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repositorio.salvar(salvo.copyWith(quantidade: 12));
    await repositorio.marcarComoSincronizado(enviado);

    // O registro deve permanecer na fila de pendências
    expect(await repositorio.listarNaoSincronizados(), hasLength(1));
  });
}

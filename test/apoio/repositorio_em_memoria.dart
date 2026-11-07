import 'package:compras/dominio/item.dart';
import 'package:compras/dominio/item_repository.dart';

/// Implementação em memória do contrato [ItemRepository], utilizada exclusivamente em testes de interface (Widget Tests).
class RepositorioEmMemoria implements ItemRepository {
  RepositorioEmMemoria([List<Item> iniciais = const []]) {
    for (final item in iniciais) {
      _itens[item.id!] = item;
    }
    _proximoId =
        _itens.keys.fold<int>(0, (maior, id) => id > maior ? id : maior) + 1;
  }

  final _itens = <int, Item>{};
  late int _proximoId;

  @override
  Future<List<Item>> listar() async => _itens.values.toList();

  @override
  Future<Item> salvar(Item item) async {
    final salvo = item.copyWith(
      id: item.id ?? _proximoId++,
      sincronizado: false,
    );
    _itens[salvo.id!] = salvo;
    return salvo;
  }

  @override
  Future<void> excluir(int id) async {
    _itens.remove(id);
  }

  @override
  Future<List<Item>> listarNaoSincronizados() async =>
      _itens.values.where((item) => !item.sincronizado).toList();

  @override
  Future<void> marcarComoSincronizado(Item item) async {
    final atual = _itens[item.id];
    if (atual != null) {
      _itens[atual.id!] = atual.copyWith(sincronizado: true);
    }
  }
}

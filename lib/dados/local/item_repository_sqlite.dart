import '../../dominio/item.dart';
import '../../dominio/item_repository.dart';
import 'banco_de_dados.dart';
import 'item_mapper.dart';

/// Implementação concreta do contrato [ItemRepository] sobre SQLite.
class ItemRepositorySqlite implements ItemRepository {
  ItemRepositorySqlite(this._banco);

  final BancoDeDados _banco;
  static const _tabela = 'itens';

  @override
  Future<List<Item>> listar() async {
    final db = await _banco.abrir();
    final linhas = await db.query(_tabela);
    return linhas.map(itemDeLinha).toList();
  }

  @override
  Future<Item> salvar(Item item) async {
    final db = await _banco.abrir();
    // Toda alteração local marca o registro como pendente de sincronização remota
    // e renova o carimbo de tempo da modificação.
    final pendente = item.copyWith(
      sincronizado: false,
      atualizadoEm: DateTime.now(),
    );
    final id = pendente.id;

    if (id == null) {
      final novoId = await db.insert(_tabela, itemParaLinha(pendente));
      return pendente.copyWith(id: novoId);
    }

    await db.update(
      _tabela,
      itemParaLinha(pendente),
      where: 'id = ?',
      whereArgs: [id],
    );
    return pendente;
  }

  @override
  Future<void> excluir(int id) async {
    final db = await _banco.abrir();
    await db.delete(_tabela, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Item>> listarNaoSincronizados() async {
    final db = await _banco.abrir();
    final linhas = await db.query(
      _tabela,
      where: 'sincronizado = 0',
    );
    return linhas.map(itemDeLinha).toList();
  }

  @override
  Future<void> marcarComoSincronizado(Item item) async {
    final db = await _banco.abrir();
    // Bloqueio otimista de concorrência: a atualização só surte efeito se o
    // registro não tiver sido alterado pelo usuário durante o período de trânsito da rede.
    await db.update(
      _tabela,
      {'sincronizado': 1},
      where: 'id = ? AND atualizado_em = ?',
      whereArgs: [item.id, item.atualizadoEm.millisecondsSinceEpoch],
    );
  }
}

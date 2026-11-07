import 'item.dart';

/// Contrato formal de persistência e consulta exigido pelo domínio.
///
/// Seguindo o princípio da inversão de dependência (DIP), o domínio
/// especifica suas necessidades nesta interface abstrata sem acoplar-se
/// a detalhes de infraestrutura (como SQLite, bases remotas ou memória).
abstract interface class ItemRepository {
  /// Recupera todos os registros de itens persistidos.
  Future<List<Item>> listar();

  /// Persiste a entidade no armazenamento.
  ///
  /// Caso o [Item.id] seja nulo, realiza inserção gerando novo identificador;
  /// caso contrário, executa atualização dos campos existentes.
  Future<Item> salvar(Item item);

  /// Remove irreversivelmente o registro associado ao [id] fornecido.
  Future<void> excluir(int id);

  /// Retorna exclusivamente os itens marcados como pendentes de sincronização (`sincronizado = false`).
  Future<List<Item>> listarNaoSincronizados();

  /// Atualiza o registro no armazenamento local demarcando-o como sincronizado,
  /// sob condição estrita de correspondência de timestamp de concorrência.
  Future<void> marcarComoSincronizado(Item item);
}

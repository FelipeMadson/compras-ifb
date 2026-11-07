/// Entidade central do domínio de compras.
///
/// Totalmente independente de frameworks de interface gráfica (Flutter),
/// bibliotecas de persistência (SQLite) ou formatos de transporte de rede (JSON/HTTP).
class Item {
  const Item({
    this.id,
    required this.nome,
    this.quantidade = 1,
    required this.categoria,
    this.observacao = '',
    this.comprado = false,
    this.sincronizado = false,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  /// Identificador numérico gerado pelo mecanismo de persistência local.
  /// Permanece nulo enquanto o item não for inserido na tabela.
  final int? id;

  /// Denominação do item a ser adquirido.
  final String nome;

  /// Quantidade demandada (compreendida estritamente no intervalo [1, 99]).
  final int quantidade;

  /// Segmento de mercado ao qual o item pertence.
  final String categoria;

  /// Especificações suplementares (marca, gramatura, instruções adicionais).
  final String observacao;

  /// Estado de aquisição do item pelo usuário.
  final bool comprado;

  /// Flag que determina se a versão atualizada localmente já foi
  /// confirmada e replicada com êxito no servidor remoto.
  final bool sincronizado;

  /// Carimbo de data/hora imutável de criação original do registro.
  final DateTime criadoEm;

  /// Carimbo de data/hora da última alteração de qualquer atributo do item.
  final DateTime atualizadoEm;

  /// Produz uma nova instância preservando o princípio da imutabilidade.
  ///
  /// O atributo [criadoEm] é propositalmente omitido das substituições
  /// para preservar a integridade histórica da gênese do dado.
  Item copyWith({
    int? id,
    String? nome,
    int? quantidade,
    String? categoria,
    String? observacao,
    bool? comprado,
    bool? sincronizado,
    DateTime? atualizadoEm,
  }) {
    return Item(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      categoria: categoria ?? this.categoria,
      observacao: observacao ?? this.observacao,
      comprado: comprado ?? this.comprado,
      sincronizado: sincronizado ?? this.sincronizado,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nome == other.nome &&
          quantidade == other.quantidade &&
          categoria == other.categoria &&
          observacao == other.observacao &&
          comprado == other.comprado &&
          sincronizado == other.sincronizado &&
          criadoEm == other.criadoEm &&
          atualizadoEm == other.atualizadoEm;

  @override
  int get hashCode => Object.hash(
        id,
        nome,
        quantidade,
        categoria,
        observacao,
        comprado,
        sincronizado,
        criadoEm,
        atualizadoEm,
      );
}

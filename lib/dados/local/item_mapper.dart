import '../../dominio/item.dart';

/// Funções de conversão bidirecional entre a entidade imutável de domínio [Item]
/// e os registros relacionais planos no SQLite.
///
/// Como o motor SQLite não possui tipos primitivos booleanos nem timestamps de alta precisão,
/// valores booleanos são mapeados para [0, 1] e datas convertidas para épocas em milissegundos.

Map<String, Object?> itemParaLinha(Item item) => {
      if (item.id != null) 'id': item.id,
      'nome': item.nome,
      'quantidade': item.quantidade,
      'categoria': item.categoria,
      'observacao': item.observacao,
      'comprado': item.comprado ? 1 : 0,
      'sincronizado': item.sincronizado ? 1 : 0,
      'criado_em': item.criadoEm.millisecondsSinceEpoch,
      'atualizado_em': item.atualizadoEm.millisecondsSinceEpoch,
    };

Item itemDeLinha(Map<String, Object?> linha) => Item(
      id: linha['id'] as int,
      nome: linha['nome'] as String,
      quantidade: linha['quantidade'] as int,
      categoria: linha['categoria'] as String,
      observacao: linha['observacao'] as String,
      comprado: (linha['comprado'] as int) == 1,
      sincronizado: (linha['sincronizado'] as int) == 1,
      criadoEm: DateTime.fromMillisecondsSinceEpoch(linha['criado_em'] as int),
      atualizadoEm: DateTime.fromMillisecondsSinceEpoch(
        linha['atualizado_em'] as int,
      ),
    );

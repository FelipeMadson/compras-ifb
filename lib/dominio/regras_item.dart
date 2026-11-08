import 'item.dart';

const tamanhoMinimoNome = 2;
const tamanhoMaximoNome = 40;
const quantidadeMinima = 1;
const quantidadeMaxima = 99;

/// Validação determinística do nome do item.
///
/// Retorna `null` quando a entrada atende aos critérios do domínio,
/// ou uma mensagem descritiva caso viole restrições de tamanho ou preenchimento.
String? validarNome(String nome) {
  final texto = nome.trim();
  if (texto.isEmpty) {
    return 'Informe o nome do item.';
  }
  if (texto.length < tamanhoMinimoNome) {
    return 'Use ao menos $tamanhoMinimoNome caracteres.';
  }
  if (texto.length > tamanhoMaximoNome) {
    return 'Use no máximo $tamanhoMaximoNome caracteres.';
  }
  return null;
}

/// Aplica incremento ou decremento à quantidade mantendo os limites [1, 99].
int ajustarQuantidade(int atual, int variacao) =>
    (atual + variacao).clamp(quantidadeMinima, quantidadeMaxima);

/// Ordenação semântica para apresentação:
///
/// 1. Prioriza itens pendentes de compra (comprado = false) sobre os já adquiridos;
/// 2. Dentro de cada agrupamento, ordena alfabeticamente pela categoria;
/// 3. Como critério de desempate secundário, ordena alfabeticamente pelo nome do item.
List<Item> ordenarParaExibicao(Iterable<Item> itens) {
  final lista = itens.toList();
  lista.sort((a, b) {
    if (a.comprado != b.comprado) {
      return a.comprado ? 1 : -1;
    }
    final porCategoria = a.categoria.toLowerCase().compareTo(
          b.categoria.toLowerCase(),
        );
    if (porCategoria != 0) {
      return porCategoria;
    }
    return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
  });
  return lista;
}

/// Representação agregada do estado da lista de compras.
class Resumo {
  const Resumo({
    required this.total,
    required this.comprados,
    required this.aguardandoEnvio,
  });

  final int total;
  final int comprados;
  final int aguardandoEnvio;

  /// Razão matemática entre itens concluídos e o montante global cadastrado.
  double get progresso => total == 0 ? 0.0 : comprados / total;

  /// Indica se todos os itens cadastrados foram marcados como adquiridos.
  bool get concluido => total > 0 && comprados == total;
}

/// Computa métricas consolidadas sobre uma coleção de itens.
Resumo resumir(Iterable<Item> itens) {
  var total = 0;
  var comprados = 0;
  var aguardandoEnvio = 0;

  for (final item in itens) {
    total++;
    if (item.comprado) {
      comprados++;
    }
    if (!item.sincronizado) {
      aguardandoEnvio++;
    }
  }

  return Resumo(
    total: total,
    comprados: comprados,
    aguardandoEnvio: aguardandoEnvio,
  );
}

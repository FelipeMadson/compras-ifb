import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;

import '../dados/local/banco_de_dados.dart';
import '../dados/local/item_repository_sqlite.dart';
import '../dados/plataforma/dispositivo_nativo.dart';
import '../dados/remoto/servico_remoto_simulado.dart';
import '../dados/sincronizador.dart';
import '../dominio/item.dart';
import '../dominio/item_repository.dart';
import '../dominio/regras_item.dart';

// ---------------------------------------------------------------------------
// Inversão de Controle e Injeção de Dependências (Composition Root)
// ---------------------------------------------------------------------------

final bancoDeDadosProvider = Provider<BancoDeDados>((ref) {
  final banco = BancoDeDados(fabrica: databaseFactory);
  ref.onDispose(banco.fechar);
  return banco;
});

final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) => ItemRepositorySqlite(ref.watch(bancoDeDadosProvider)),
);

final servicoRemotoProvider = Provider<ServicoRemotoSimulado>(
  (ref) => ServicoRemotoSimulado(),
);

final sincronizadorProvider = Provider<Sincronizador>(
  (ref) => Sincronizador(
    ref.watch(itemRepositoryProvider),
    ref.watch(servicoRemotoProvider),
  ),
);

final dispositivoNativoProvider = Provider<DispositivoNativo>(
  (ref) => DispositivoNativo(),
);

// ---------------------------------------------------------------------------
// Provedores de Estado Reativo
// ---------------------------------------------------------------------------

/// Observador de telemetria de conectividade física.
final conectividadeProvider = StreamProvider<bool>((ref) async* {
  final conectividade = Connectivity();
  yield _estaOnline(await conectividade.checkConnectivity());
  yield* conectividade.onConnectivityChanged.map(_estaOnline);
});

bool _estaOnline(List<ConnectivityResult> resultados) =>
    resultados.isNotEmpty && !resultados.contains(ConnectivityResult.none);

/// Consulta as especificações de hardware entregues pelo canal nativo.
final infoDispositivoProvider = FutureProvider<InfoDispositivo?>(
  (ref) => ref.watch(dispositivoNativoProvider).obterInformacoes(),
);

/// Consulta o metadado persistido de data de instanciação inicial do banco SQLite.
final bancoCriadoEmProvider = FutureProvider<DateTime?>((ref) async {
  final valor = await ref.watch(bancoDeDadosProvider).lerMetadado('criado_em');
  return valor == null ? null : DateTime.parse(valor);
});

/// Notifier reativo para controle da lista de itens e operações de mutação.
final itensProvider = AsyncNotifierProvider<ItensNotifier, List<Item>>(
  ItensNotifier.new,
);

/// Filtro de categoria ativa (null representa todas as categorias).
final filtroCategoriaProvider = StateProvider<String?>((ref) => null);

/// Termo de busca digitado pelo usuário para filtragem rápida.
final buscaTextoProvider = StateProvider<String>((ref) => '');

/// Coleção derivada de itens aplicando filtros de categoria e busca.
final itensFiltradosProvider = Provider<AsyncValue<List<Item>>>((ref) {
  final itensAsync = ref.watch(itensProvider);
  final categoria = ref.watch(filtroCategoriaProvider);
  final busca = ref.watch(buscaTextoProvider).trim().toLowerCase();

  return itensAsync.whenData((itens) {
    if (categoria == null && busca.isEmpty) return itens;
    return itens.where((item) {
      final bateCategoria = categoria == null || item.categoria == categoria;
      final bateBusca = busca.isEmpty ||
          item.nome.toLowerCase().contains(busca) ||
          item.observacao.toLowerCase().contains(busca);
      return bateCategoria && bateBusca;
    }).toList();
  });
});

class ItensNotifier extends AsyncNotifier<List<Item>> {
  ItemRepository get _repositorio => ref.read(itemRepositoryProvider);

  @override
  Future<List<Item>> build() async {
    final itens = await ref.watch(itemRepositoryProvider).listar();
    return ordenarParaExibicao(itens);
  }

  Future<void> salvar(Item item) async {
    await _repositorio.salvar(item);
    await _recarregar();
  }

  Future<void> alternarComprado(Item item) =>
      salvar(item.copyWith(comprado: !item.comprado));

  Future<void> excluir(Item item) async {
    final id = item.id;
    if (id == null) return;

    // Remoção otimista imediata na interface, exigência estrutural do Dismissible.
    if (state case AsyncData(:final value)) {
      state = AsyncData([
        for (final i in value)
          if (i.id != id) i,
      ]);
    }

    try {
      await _repositorio.excluir(id);
    } catch (_) {
      // Reversão do estado em caso de falha de persistência
      await _recarregar();
      rethrow;
    }
  }

  Future<void> _recarregar() async {
    state = AsyncData(ordenarParaExibicao(await _repositorio.listar()));
  }
}

class EstadoSincronizacao {
  const EstadoSincronizacao({this.emAndamento = false, this.mensagem});

  final bool emAndamento;
  final String? mensagem;
}

final sincronizacaoProvider =
    NotifierProvider<SincronizacaoNotifier, EstadoSincronizacao>(
  SincronizacaoNotifier.new,
);

class SincronizacaoNotifier extends Notifier<EstadoSincronizacao> {
  @override
  EstadoSincronizacao build() => const EstadoSincronizacao();

  Future<void> sincronizar() async {
    if (state.emAndamento) return;

    final online = switch (ref.read(conectividadeProvider)) {
      AsyncData(:final value) => value,
      _ => false,
    };

    if (!online) {
      state = const EstadoSincronizacao(
        mensagem: 'Sem conexão de rede. As alterações permanecem salvas localmente.',
      );
      return;
    }

    state = const EstadoSincronizacao(emAndamento: true);
    try {
      final resultado = await ref.read(sincronizadorProvider).sincronizar();
      state = EstadoSincronizacao(
        mensagem: resultado.falhas == 0
            ? 'Sincronização concluída: ${resultado.enviados} item(ns) enviado(s).'
            : 'Enviado(s) ${resultado.enviados} item(ns); ${resultado.falhas} permaneceu(ram) pendente(s).',
      );
    } catch (erro) {
      state = EstadoSincronizacao(mensagem: 'Falha durante o envio: $erro');
    }

    ref.invalidate(itensProvider);
  }
}

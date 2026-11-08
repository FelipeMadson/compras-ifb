import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/identidade.dart';
import '../../dominio/item.dart';
import '../../dominio/regras_item.dart';
import '../componentes/cartao_item.dart';
import '../componentes/faixa_offline.dart';
import '../providers.dart';

class TelaLista extends ConsumerWidget {
  const TelaLista({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itensAsync = ref.watch(itensProvider);

    final online = switch (ref.watch(conectividadeProvider)) {
      AsyncData(:final value) => value,
      _ => true,
    };

    final sincronizando = ref.watch(
      sincronizacaoProvider.select((estado) => estado.emAndamento),
    );

    // Reatividade a transição de estado de rede: dispara sincronização automática no restabelecimento.
    ref.listen(conectividadeProvider, (anterior, atual) {
      final reconectou = anterior is AsyncData<bool> &&
          !anterior.value &&
          atual is AsyncData<bool> &&
          atual.value;
      if (reconectou) {
        ref.read(sincronizacaoProvider.notifier).sincronizar();
      }
    });

    // Exibição de feedback contextual não bloqueante (SnackBar).
    ref.listen(sincronizacaoProvider, (anterior, atual) {
      final mensagem = atual.mensagem;
      if (!atual.emAndamento && mensagem != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(mensagem)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(Identidade.nomeDoApp),
        actions: [
          IconButton(
            tooltip: 'Sincronizar alterações pendentes',
            onPressed: sincronizando
                ? null
                : () => ref.read(sincronizacaoProvider.notifier).sincronizar(),
            icon: sincronizando
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
          ),
          IconButton(
            tooltip: 'Sobre o aplicativo e créditos',
            onPressed: () => context.go('/sobre'),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/item/novo'),
        icon: const Icon(Icons.add),
        label: const Text('Novo item'),
      ),
      body: Column(
        children: [
          if (!online) const FaixaOffline(),
          Expanded(
            child: itensAsync.when(
              data: (itens) => _Conteudo(itens: itens),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (erro, _) => _Falha(
                erro: erro,
                aoTentarNovamente: () => ref.invalidate(itensProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Conteudo extends ConsumerWidget {
  const _Conteudo({super.key, required this.itens});

  final List<Item> itens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (itens.isEmpty) return const _EstadoVazio();

    final itensFiltradosAsync = ref.watch(itensFiltradosProvider);
    final itensExibidos = itensFiltradosAsync.value ?? itens;
    final categoriaSelecionada = ref.watch(filtroCategoriaProvider);
    final termoBusca = ref.watch(buscaTextoProvider);
    final resumo = resumir(itens);

    // Altura base proporcional à escala de fonte do sistema operacional (Acessibilidade WCAG).
    final alturaDoCartao = MediaQuery.textScalerOf(context).scale(84);

    return LayoutBuilder(
      builder: (context, restricoes) {
        // Breakpoints responsivos recomendados pelo Material Design: 600dp e 840dp.
        final colunas = restricoes.maxWidth < 600
            ? 1
            : restricoes.maxWidth < 840
                ? 2
                : 3;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _CabecalhoResumo(resumo: resumo)),
            SliverToBoxAdapter(
              child: _BarraDePesquisaEFiltros(
                todosOsItens: itens,
                categoriaSelecionada: categoriaSelecionada,
                termoBusca: termoBusca,
                aoSelecionarCategoria: (cat) {
                  ref.read(filtroCategoriaProvider.notifier).state = cat;
                },
                aoMudarBusca: (txt) {
                  ref.read(buscaTextoProvider.notifier).state = txt;
                },
              ),
            ),
            if (itensExibidos.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 44,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum item correspondente encontrado.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.read(filtroCategoriaProvider.notifier).state = null;
                            ref.read(buscaTextoProvider.notifier).state = '';
                          },
                          child: const Text('Limpar filtros'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                // Espaçamento inferior de 96dp para desobstrução visual do FloatingActionButton.
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: colunas,
                    mainAxisExtent: alturaDoCartao,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: itensExibidos.length,
                  itemBuilder: (context, i) => CartaoItem(item: itensExibidos[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BarraDePesquisaEFiltros extends StatelessWidget {
  const _BarraDePesquisaEFiltros({
    required this.todosOsItens,
    required this.categoriaSelecionada,
    required this.termoBusca,
    required this.aoSelecionarCategoria,
    required this.aoMudarBusca,
  });

  final List<Item> todosOsItens;
  final String? categoriaSelecionada;
  final String termoBusca;
  final ValueChanged<String?> aoSelecionarCategoria;
  final ValueChanged<String> aoMudarBusca;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de busca linear rápido
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: cores.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cores.outlineVariant),
            ),
            child: TextField(
              onChanged: aoMudarBusca,
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintText: 'Filtrar por nome ou observação...',
                hintStyle: TextStyle(
                  color: cores.outline.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: cores.outline,
                ),
                suffixIcon: termoBusca.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => aoMudarBusca(''),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Chips de categorias horizontais
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ChipCategoria(
                  rotulo: 'Todas',
                  quantidade: todosOsItens.length,
                  selecionado: categoriaSelecionada == null,
                  aoClicar: () => aoSelecionarCategoria(null),
                ),
                for (final cat in Identidade.categorias)
                  _ChipCategoria(
                    rotulo: cat,
                    icone: Identidade.iconeDaCategoria(cat),
                    cor: Identidade.corDaCategoria(cat),
                    quantidade: todosOsItens.where((i) => i.categoria == cat).length,
                    selecionado: categoriaSelecionada == cat,
                    aoClicar: () => aoSelecionarCategoria(
                      categoriaSelecionada == cat ? null : cat,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipCategoria extends StatelessWidget {
  const _ChipCategoria({
    required this.rotulo,
    required this.quantidade,
    required this.selecionado,
    required this.aoClicar,
    this.icone,
    this.cor,
  });

  final String rotulo;
  final int quantidade;
  final bool selecionado;
  final VoidCallback aoClicar;
  final IconData? icone;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final corAcento = cor ?? cores.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: selecionado
            ? corAcento.withValues(alpha: 0.18)
            : cores.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: aoClicar,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selecionado
                    ? corAcento
                    : cores.outlineVariant.withValues(alpha: 0.8),
                width: selecionado ? 1.2 : 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icone != null) ...[
                  Icon(icone, size: 12, color: selecionado ? corAcento : cores.outline),
                  const SizedBox(width: 5),
                ],
                Text(
                  rotulo,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
                    color: selecionado ? corAcento : cores.onSurface,
                  ),
                ),
                if (quantidade > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: selecionado
                          ? corAcento.withValues(alpha: 0.25)
                          : cores.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$quantidade',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: selecionado ? corAcento : cores.outline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CabecalhoResumo extends StatelessWidget {
  const _CabecalhoResumo({required this.resumo});

  final Resumo resumo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textos = tema.textTheme;
    final cores = tema.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: cores.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        color: cores.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Progresso das Compras',
                        style: textos.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cores.onSurface,
                          letterSpacing: -0.01,
                        ),
                      ),
                      if (resumo.concluido && resumo.total > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cores.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '100% concluído',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: cores.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${resumo.comprados} de ${resumo.total} itens',
                    style: textos.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: cores.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: resumo.progresso),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder: (context, valor, _) {
                    return LinearProgressIndicator(
                      value: valor,
                      minHeight: 6,
                      backgroundColor: cores.surfaceContainerHighest,
                    );
                  },
                ),
              ),
              if (resumo.aguardandoEnvio > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 16,
                      color: cores.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${resumo.aguardandoEnvio} modificação(ões) pendente(s) de sincronização.',
                      style: textos.bodySmall?.copyWith(color: cores.error),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cores.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cores.outlineVariant),
              ),
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 48,
                color: cores.outline,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhum item na lista',
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01,
              ),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                'Toque em "Novo item" para iniciar o registro de compras.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cores.onSurfaceVariant,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Falha extends StatelessWidget {
  const _Falha({required this.erro, required this.aoTentarNovamente});

  final Object erro;
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Incapaz de carregar os registros locais do banco SQLite.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$erro',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: aoTentarNovamente,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

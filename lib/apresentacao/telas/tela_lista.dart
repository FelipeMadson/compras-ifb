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

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.itens});

  final List<Item> itens;

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) return const _EstadoVazio();

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
                itemCount: itens.length,
                itemBuilder: (context, i) => CartaoItem(item: itens[i]),
              ),
            ),
          ],
        );
      },
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
          borderRadius: BorderRadius.circular(12),
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
                  Text(
                    'Progresso das Compras',
                    style: textos.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cores.onSurface,
                    ),
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
              const SizedBox(height: 10),
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 64,
              color: tema.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text('Nenhum item na lista', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Toque em "Novo item" para iniciar o registro de compras.',
              textAlign: TextAlign.center,
              style: TextStyle(color: tema.colorScheme.onSurfaceVariant),
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

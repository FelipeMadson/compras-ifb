import 'package:compras/app.dart';
import 'package:compras/apresentacao/providers.dart';
import 'package:compras/dominio/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/repositorio_em_memoria.dart';

void main() {
  testWidgets('fluxo completo: renderiza listagem persistida e cadastra novo item', (tester) async {
    final data = DateTime(2026, 1, 1);
    final repositorio = RepositorioEmMemoria([
      Item(
        id: 1,
        nome: 'Arroz Parboilizado',
        categoria: 'Mercearia',
        criadoEm: data,
        atualizadoEm: data,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemRepositoryProvider.overrideWithValue(repositorio),
          conectividadeProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: const AppCompras(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Arroz Parboilizado'), findsOneWidget);

    // Validação de formulário: submissão com campo obrigatório vazio
    await tester.tap(find.text('Novo item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar à lista'));
    await tester.pump();
    expect(find.text('Informe o nome do item.'), findsOneWidget);

    // Preenchimento e persistência bem-sucedida
    await tester.enterText(find.byType(TextFormField).first, 'Café Torrado');
    await tester.tap(find.text('Adicionar à lista'));
    await tester.pumpAndSettle();

    expect(find.text('Café Torrado'), findsOneWidget);
    expect(find.text('Arroz Parboilizado'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/identidade.dart';
import '../providers.dart';

/// Tela institucional com créditos acadêmicos, diagnóstico de hardware via canal nativo e metadados SQLite.
class TelaSobre extends ConsumerWidget {
  const TelaSobre({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final textos = tema.textTheme;
    final cores = tema.colorScheme;
    final dispositivo = ref.watch(infoDispositivoProvider);
    final bancoCriadoEm = ref.watch(bancoCriadoEmProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o Projeto')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                // Cartão de Cabeçalho do App
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cores.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cores.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cores.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cores.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 32,
                          color: cores.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Identidade.nomeDoApp,
                              style: textos.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.02,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cores.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: cores.outlineVariant.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Text(
                                'Versão 1.0.0 · Build 1 · DPDMV 2026/2',
                                style: textos.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  color: cores.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  Identidade.descricao,
                  style: textos.bodyMedium?.copyWith(
                    color: cores.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const Divider(height: 36),
                // Seção Autoria Acadêmica
                Text(
                  'Autoria e Vínculo Institucional',
                  style: textos.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.01,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: cores.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cores.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      for (final integrante in Identidade.integrantes)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: cores.primary.withValues(alpha: 0.15),
                                child: Text(
                                  integrante.nome.substring(0, 1),
                                  style: TextStyle(
                                    color: cores.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      integrante.nome,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Matrícula institucional: ${integrante.matricula}',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: cores.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Divider(height: 1, color: cores.outlineVariant.withValues(alpha: 0.5)),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: cores.surfaceContainerHighest,
                              child: Icon(Icons.school_outlined, color: cores.outline, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tecnologia em Sistemas para Internet (TSI)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${Identidade.turma} · Docente: Prof. Me. Cláudio Ulhoa',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: cores.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 36),
                // Seção Diagnóstico do Hardware Nativo (Kotlin)
                Text(
                  'Dispositivo (Canal Nativo Kotlin / MethodChannel)',
                  style: textos.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.01,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cores.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cores.outlineVariant),
                  ),
                  child: dispositivo.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (erro, _) => Text(
                      'Falha na consulta ao canal nativo: $erro',
                      style: TextStyle(color: cores.error),
                    ),
                    data: (info) => info == null
                        ? const Text(
                            'Canal nativo indisponível nesta plataforma de execução.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ItemInfo(
                                rotulo: 'Fabricante e Modelo',
                                valor: '${info.fabricante} ${info.modelo}',
                                icone: Icons.smartphone_outlined,
                              ),
                              const SizedBox(height: 12),
                              _ItemInfo(
                                rotulo: 'Versão do Android',
                                valor: 'Android ${info.versaoAndroid}',
                                icone: Icons.android_outlined,
                              ),
                              const SizedBox(height: 12),
                              _ItemInfo(
                                rotulo: 'Nível de Carga da Bateria',
                                valor: '${info.nivelBateria}%',
                                icone: Icons.battery_charging_full_outlined,
                              ),
                            ],
                          ),
                  ),
                ),
                const Divider(height: 36),
                // Seção Persistência Relacional Local
                Text(
                  'Persistência Relacional Local (SQLite)',
                  style: textos.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.01,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cores.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cores.outlineVariant),
                  ),
                  child: bancoCriadoEm.when(
                    loading: () => const Text('Consultando tabela de metadados...'),
                    error: (erro, _) => Text(
                      'Erro ao consultar metadados do SQLite: $erro',
                      style: TextStyle(color: cores.error),
                    ),
                    data: (data) => _ItemInfo(
                      rotulo: 'Instanciação do Banco SQLite',
                      valor: data == null
                          ? 'Data de criação não registrada.'
                          : 'Arquivo criado no armazenamento privado em ${_formatar(data)}.',
                      icone: Icons.storage_outlined,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemInfo extends StatelessWidget {
  const _ItemInfo({
    required this.rotulo,
    required this.valor,
    this.icone,
  });

  final String rotulo;
  final String valor;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icone != null) ...[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cores.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icone, size: 16, color: cores.primary),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rotulo,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cores.primary,
                  letterSpacing: -0.01,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 13.5,
                  color: cores.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatar(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(data.day)}/${dois(data.month)}/${data.year} às ${dois(data.hour)}:${dois(data.minute)}';
}

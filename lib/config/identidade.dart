import 'package:flutter/material.dart';

/// Registro de identificação de integrante da equipe de desenvolvimento.
class Integrante {
  const Integrante({required this.nome, required this.matricula});

  final String nome;
  final String matricula;
}

/// Identificação do aplicativo, autoria, parametrização visual e catálogo base.
///
/// Centraliza os tokens fundamentais de identidade conforme especificado
/// na arquitetura do projeto para a disciplina DPDMV 2026/2.
abstract final class Identidade {
  /// Nome de exibição na barra superior e na tela de créditos/sobre.
  static const nomeDoApp = 'Lista de Compras IFB';

  /// Síntese técnica do propósito do aplicativo.
  static const descricao =
      'Aplicativo móvel com persistência relacional local em SQLite, '
      'sincronização resiliente com nova tentativa exponencial (jitter) '
      'e integração com serviços de plataforma via canal nativo Android.';

  static const turma =
      'Desenvolvimento para Dispositivos Móveis 2026/2 — IFB Campus Brasília';

  static const integrantes = [
    Integrante(
      nome: 'Felipe Madison da Silva Veloso',
      matricula: '69815',
    ),
  ];

  /// Cor semente utilizada na geração dinâmica da paleta Material 3 (M3).
  static const corSemente = Color(0xFF00695C);

  /// Categorias padrão ofertadas no cadastro de itens de compra.
  static const categorias = [
    'Hortifrúti',
    'Mercearia',
    'Laticínios',
    'Açougue e Frios',
    'Padaria',
    'Bebidas',
    'Limpeza',
    'Higiene Pessoal',
  ];
}

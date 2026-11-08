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

  /// Retorna o ícone contextual e semântico representativo de cada categoria.
  static IconData iconeDaCategoria(String categoria) {
    return switch (categoria) {
      'Hortifrúti' => Icons.eco_outlined,
      'Mercearia' => Icons.shopping_basket_outlined,
      'Laticínios' => Icons.egg_outlined,
      'Açougue e Frios' => Icons.restaurant_outlined,
      'Padaria' => Icons.bakery_dining_outlined,
      'Bebidas' => Icons.local_cafe_outlined,
      'Limpeza' => Icons.cleaning_services_outlined,
      'Higiene Pessoal' => Icons.spa_outlined,
      _ => Icons.category_outlined,
    };
  }

  /// Retorna a cor de acentuação categórica no padrão Linear.
  static Color corDaCategoria(String categoria) {
    return switch (categoria) {
      'Hortifrúti' => const Color(0xFF10B981),
      'Mercearia' => const Color(0xFFF59E0B),
      'Laticínios' => const Color(0xFF06B6D4),
      'Açougue e Frios' => const Color(0xFFF43F5E),
      'Padaria' => const Color(0xFFD97706),
      'Bebidas' => const Color(0xFF8B5CF6),
      'Limpeza' => const Color(0xFF0284C7),
      'Higiene Pessoal' => const Color(0xFF14B8A6),
      _ => const Color(0xFF6B7280),
    };
  }
}

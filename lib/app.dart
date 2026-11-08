import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'apresentacao/rotas.dart';
import 'config/identidade.dart';

/// Ponto de entrada do aplicativo com configuração de tema refinado Linear/Apple HIG.
class AppCompras extends ConsumerWidget {
  const AppCompras({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tema Escuro (Padrão Primário Linear-Apple)
    final temaEscuro = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF090A0F),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF10B981),
        brightness: Brightness.dark,
        surface: const Color(0xFF0F121C),
        surfaceContainerLow: const Color(0xFF121622),
        surfaceContainerHighest: const Color(0xFF1A1F30),
        outlineVariant: const Color(0xFF22283A),
        outline: const Color(0xFF6B7280),
        primary: const Color(0xFF10B981),
        onPrimary: const Color(0xFF000000),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF090A0F),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFF4F4F6),
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
        iconTheme: IconThemeData(color: Color(0xFFF4F4F6)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: const Color(0xFF121622),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF22283A), width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF121622),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF22283A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF22283A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF9496A3), fontSize: 14),
        prefixIconColor: const Color(0xFF9496A3),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 4,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF10B981);
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFF000000)),
        side: const BorderSide(color: Color(0xFF3B4257), width: 1.5),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E2436),
        thickness: 1,
        space: 24,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: const Color(0xFF000000),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
          ),
        ),
      ),
    );

    // Tema Claro (Refinado e de Alto Contraste)
    final temaClaro = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF059669),
        brightness: Brightness.light,
        surface: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFFFFFFF),
        surfaceContainerHighest: const Color(0xFFF1F5F9),
        outlineVariant: const Color(0xFFE2E8F0),
        outline: const Color(0xFF94A3B8),
        primary: const Color(0xFF059669),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF059669);
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 24,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: const Color(0xFFFFFFFF),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
          ),
        ),
      ),
    );

    return MaterialApp.router(
      title: Identidade.nomeDoApp,
      debugShowCheckedModeBanner: false,
      theme: temaClaro,
      darkTheme: temaEscuro,
      themeMode: ThemeMode.system, // Adaptação nativa automática ao tema do sistema operacional
      routerConfig: ref.watch(roteadorProvider),
    );
  }
}

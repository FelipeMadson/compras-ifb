import 'dart:math';
import 'package:flutter/material.dart';

/// Efeito visual de partículas geométricas com física de aceleração cúbica e rotação.
/// Ativado em comemorações de conclusão da lista de compras (60 FPS puro sem dependências externas).
class ParticulasCelebracao extends StatefulWidget {
  const ParticulasCelebracao({super.key});

  @override
  State<ParticulasCelebracao> createState() => _ParticulasCelebracaoState();
}

class _ParticulasCelebracaoState extends State<ParticulasCelebracao>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particula> _particulas;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _particulas = List.generate(42, (i) {
      final angulo = random.nextDouble() * 2 * pi;
      final velocidade = 90.0 + random.nextDouble() * 200.0;
      final tamanho = 4.0 + random.nextDouble() * 6.0;
      final cor = [
        const Color(0xFF14B8A6), // Esmeralda / Teal
        const Color(0xFF38BDF8), // Ciano Elétrico
        const Color(0xFF10B981), // Verde Sucesso
        const Color(0xFFF59E0B), // Âmbar Dourado
        const Color(0xFFA855F7), // Roxo Neon
      ][i % 5];
      return _Particula(
        angulo: angulo,
        velocidade: velocidade,
        tamanho: tamanho,
        cor: cor,
        rotacao: random.nextDouble() * pi,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.value >= 1.0) return const SizedBox.shrink();
          return CustomPaint(
            size: Size.infinite,
            painter: _ParticulasPainter(
              progresso: _controller.value,
              particulas: _particulas,
            ),
          );
        },
      ),
    );
  }
}

class _Particula {
  const _Particula({
    required this.angulo,
    required this.velocidade,
    required this.tamanho,
    required this.cor,
    required this.rotacao,
  });

  final double angulo;
  final double velocidade;
  final double tamanho;
  final Color cor;
  final double rotacao;
}

class _ParticulasPainter extends CustomPainter {
  const _ParticulasPainter({
    required this.progresso,
    required this.particulas,
  });

  final double progresso;
  final List<_Particula> particulas;

  @override
  void paint(Canvas canvas, Size size) {
    if (progresso >= 1.0) return;

    final centroX = size.width / 2;
    final centroY = size.height * 0.22;
    final opacidade = ((1.0 - progresso) * 255).clamp(0, 255).toInt();

    for (final p in particulas) {
      final distancia = p.velocidade * Curves.easeOutCubic.transform(progresso);
      final dx = centroX + cos(p.angulo) * distancia;
      final dy = centroY + sin(p.angulo) * distancia + (progresso * 70);

      final paint = Paint()
        ..color = p.cor.withAlpha(opacidade)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.rotacao + progresso * pi * 2.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.tamanho,
            height: p.tamanho * 0.65,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticulasPainter oldDelegate) =>
      oldDelegate.progresso != progresso;
}

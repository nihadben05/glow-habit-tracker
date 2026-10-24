import 'package:flutter/material.dart';
import '../utils/theme.dart';

class PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  const PrimaryBtn({super.key, required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.purple, AppColors.orange],
        ),
        boxShadow: [BoxShadow(color: AppColors.purple.withValues(alpha: .3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: loading
          ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          : Text(label, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: .3)),
    ),
  );
}

class GhostBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const GhostBtn({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.surf3, width: 1.5),
      ),
      child: Text(label, textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.txt2, fontSize: 15, fontWeight: FontWeight.w500)),
    ),
  );
}

class GlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double radius;
  const GlowCard({super.key, required this.child, this.padding, this.margin, this.radius = 20});

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: padding ?? const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surf,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.divider),
      boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: child,
  );
}

class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.txt)),
      ...? (trailing != null ? [trailing!] : null),
    ],
  );
}

class AppChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color colorL;
  const AppChip({super.key, required this.label, required this.color, required this.colorL});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: colorL, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
  );
}

class ColorPicker extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onChanged;
  const ColorPicker({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10, runSpacing: 10,
    children: AppColors.accentColors.map((c) {
      final sel = c == selected;
      return GestureDetector(
        onTap: () => onChanged(c),
        child: AnimatedScale(
          scale: sel ? 1.12 : 1,
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: c,
              border: Border.all(color: sel ? AppColors.txt.withValues(alpha: .35) : Colors.transparent, width: 3),
              boxShadow: sel ? [BoxShadow(color: c.withValues(alpha: .4), blurRadius: 10)] : [],
            ),
            child: sel ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
          ),
        ),
      );
    }).toList(),
  );

}

class SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  const SheetField({
    super.key, required this.controller, required this.label,
    required this.hint, this.maxLines = 1, this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.txt2, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.txt, fontSize: 15),
        decoration: InputDecoration(hintText: hint),
      ),
    ],
  );
}

class GradientProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final List<Color> colors;
  const GradientProgressBar({super.key, required this.value, this.height = 8, this.colors = const [AppColors.purple, AppColors.gold]});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(50),
    child: Stack(children: [
      Container(height: height, color: AppColors.surf3),
      FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    ]),
  );
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.bg.withValues(alpha: .7),
    child: const Center(child: CircularProgressIndicator(color: AppColors.purple)),
  );
}

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  const EmptyState({super.key, required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 52)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.txt)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.txt3, height: 1.5)),
      ]),
    ),
  );
}

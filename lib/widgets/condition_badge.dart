import 'package:material_ui/material_ui.dart';

/// Small pill showing a listing's condition, colour-coded by grade.
class ConditionBadge extends StatelessWidget {
  const ConditionBadge({super.key, required this.condition, this.isSold = false});

  final String condition;
  final bool isSold;

  Color _color(BuildContext context) {
    if (isSold) return Colors.grey;
    switch (condition) {
      case 'Like New':
        return Colors.green;
      case 'Good':
        return Colors.teal;
      case 'Fair':
        return Colors.amber.shade800;
      case 'Heavily Used':
        return Colors.deepOrange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        isSold ? 'SOLD' : condition,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

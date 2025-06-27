import 'package:flutter/material.dart';

class RatingsWidget extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const RatingsWidget({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: size,
          color: color,
        );
      }),
    );
  }
}
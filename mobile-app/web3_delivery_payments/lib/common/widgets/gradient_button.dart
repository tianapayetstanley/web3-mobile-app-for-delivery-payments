import 'package:flutter/material.dart';

class GradientElevatedButton extends StatelessWidget {
  final LinearGradient gradient;
  final Widget child;
  final VoidCallback onPressed;

  const GradientElevatedButton({
    Key? key,
    required this.gradient,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 44.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99.0),
        gradient: gradient,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99.0),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

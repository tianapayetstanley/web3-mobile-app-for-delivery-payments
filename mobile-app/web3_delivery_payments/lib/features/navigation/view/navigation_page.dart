import 'package:flutter/material.dart';
import 'package:web3_delivery_payments/features/navigation/widgets/map_widget.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MapWidget(),
    );
  }
}

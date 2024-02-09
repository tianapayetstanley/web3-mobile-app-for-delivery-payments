import 'package:flutter/material.dart';
import 'package:web3_delivery_payments/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Web3 Based Delivery Payment',
      debugShowCheckedModeBanner: false,
      routerConfig: MyRouter.router,
    );
  }
}

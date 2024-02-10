import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web3_delivery_payments/common/widgets/gradient_button.dart';
import 'package:web3_delivery_payments/router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4ade80),
              Color(0xFF3b82f6),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(top: 90, left: 20),
                child: const Column(
                  children: [
                    Icon(
                      Icons.fire_truck,
                      size: 100.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Are you ready to start your delivery?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
            Flexible(
              child: GradientElevatedButton(
                onPressed: () {
                  context.pushNamed(MyRouter.navigationRouteName);
                },
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFc084fc),
                      Color(0xFFec4899),
                      Color(0xFFef4444),
                    ]),
                child: const Text('Start Delivery'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

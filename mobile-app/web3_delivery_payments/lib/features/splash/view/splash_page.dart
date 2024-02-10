import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web3_delivery_payments/router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // move to login page after 2 seconds
    Future.delayed(
      const Duration(seconds: 2),
      () => context.goNamed(MyRouter.homeRouteName),
    );
    super.initState();
  }

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Spacer(),
              Icon(
                Icons.vpn_lock,
                size: 100.0,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'Web3 Based Delivery Payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Prepare to dive into the future',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

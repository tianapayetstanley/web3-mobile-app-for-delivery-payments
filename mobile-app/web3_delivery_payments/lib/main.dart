import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:web3_delivery_payments/common/blocs/bloc_observer.dart';
import 'package:web3_delivery_payments/common/repositories/smart_contract_repository.dart';
import 'package:web3_delivery_payments/router.dart';

void main() {
  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SmartContractRepository(),
      child: MaterialApp.router(
        title: 'Web3 Based Delivery Payment',
        debugShowCheckedModeBanner: false,
        routerConfig: MyRouter.router,
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
      ),
    );
  }
}

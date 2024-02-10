import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web3_delivery_payments/common/blocs/bloc_observer.dart';
import 'package:web3_delivery_payments/common/repositories/smart_contract_repository.dart';
import 'package:web3_delivery_payments/features/navigation/bloc/navigation_bloc.dart';
import 'package:web3_delivery_payments/features/navigation/repository/geolocation_repository.dart';
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
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => SmartContractRepository(),
          ),
          RepositoryProvider(
            create: (context) => GeoLocationRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => NavigationBloc(),
            ),
          ],
          child: MaterialApp.router(
            title: 'Web3 Based Delivery Payment',
            debugShowCheckedModeBanner: false,
            routerConfig: MyRouter.router,
            theme: ThemeData(
                textTheme: GoogleFonts.poppinsTextTheme(
                  Theme.of(context).textTheme,
                ),
                snackBarTheme: const SnackBarThemeData(
                  behavior: SnackBarBehavior.floating,
                )),
          ),
        ));
  }
}

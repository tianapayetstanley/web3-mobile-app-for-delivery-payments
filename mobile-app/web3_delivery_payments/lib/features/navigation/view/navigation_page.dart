import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web3_delivery_payments/common/widgets/snackbar_widget.dart';
import 'package:web3_delivery_payments/features/navigation/bloc/navigation_bloc.dart';
import 'package:web3_delivery_payments/features/navigation/widgets/map_widget.dart';
import 'package:web3_delivery_payments/router.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  @override
  void initState() {
    context.read<NavigationBloc>().add(GetCurrentPosition());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<NavigationBloc, NavigationState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == NavigationStatus.error) {
                showSnackbar(
                    context, SnackbarType.error, state.failure.message);
              }

              if (state.status == NavigationStatus.completed) {
                // show alert dialog
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Success"),
                        content: const Text(
                            'Delivery completed. Await for the admin to dispose the funds.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              context.goNamed(MyRouter.homeRouteName);
                            },
                            child: Text('Ok'),
                          ),
                        ],
                      );
                    });
              }
            },
          ),
          BlocListener<NavigationBloc, NavigationState>(
            listenWhen: (previous, current) =>
                previous.geoStatus != current.geoStatus,
            listener: (context, state) {
              if (state.geoStatus == GeoStatus.permissionDenied ||
                  state.geoStatus == GeoStatus.permissionDeniedPermanently ||
                  state.geoStatus == GeoStatus.serviceDisabled) {
                showSnackbar(
                    context, SnackbarType.error, state.failure.message);
              }
            },
          ),
        ],
        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            if (state.status == NavigationStatus.initial ||
                state.status == NavigationStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.geoStatus != GeoStatus.loaded) {
              return const Center(child: CircularProgressIndicator());
            }
            return const MapWidget();
          },
        ),
      ),
    );
  }
}

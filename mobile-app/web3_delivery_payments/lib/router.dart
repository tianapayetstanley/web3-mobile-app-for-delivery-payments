import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web3_delivery_payments/features/home/view/home_page.dart';
import 'package:web3_delivery_payments/features/navigation/view/navigation_page.dart';
import 'package:web3_delivery_payments/features/splash/view/splash_page.dart';

class MyRouter {
  static String splashRouteName = '/splash';
  static String homeRouteName = '/';
  static String navigationRouteName = '/navigation';

  static GoRouter router = GoRouter(
    debugLogDiagnostics: kDebugMode,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        name: splashRouteName,
        path: '/splash',
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: SplashPage());
        },
      ),
      GoRoute(
        name: homeRouteName,
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        name: navigationRouteName,
        path: '/navigation',
        builder: (context, state) => const NavigationPage(),
      )
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          state.error == null ? 'Something went wrong' : state.error.toString(),
        ),
      ),
    ),
    redirect: (context, state) {
      //Returns null to say you are not redirecting.
      return null;
    },
  );
}

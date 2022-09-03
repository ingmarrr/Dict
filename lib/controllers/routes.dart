import 'package:dict/pages/home.dart';
import 'package:dict/shared/extensions.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routingData = settings.name!.routingData;

    switch (routingData.path) {
      case HomePage.id:
        return move(const HomePage(), settings);
      default:
        return _errorRoute();
    }
  }

  static PageRouteBuilder<dynamic> move(Widget target, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => target,
      transitionDuration: const Duration(milliseconds: 0),
      transitionsBuilder: (context, animation, anotherAnimation, child) {
        animation = CurvedAnimation(
          curve: Curves.easeIn,
          parent: animation,
        );
        return Align(
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: 0.0,
            child: child,
          ),
        );
      },
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}

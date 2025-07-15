import 'package:flutter/material.dart';
import 'package:flutter_inject0r_example/home_page.dart';
import 'package:flutter_inject0r_example/scoped_go_route.dart';
import 'package:flutter_inject0r_example/test_page.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: GoRouter(
        routes: [
          ScopedGoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
            routes: [
              ScopedGoRoute(
                path: 'test',
                builder: (context, state) => const TestPage(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

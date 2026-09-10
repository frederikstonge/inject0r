import 'package:material_ui/material_ui.dart';
import 'home_page.dart';
import 'scoped_go_route.dart';
import 'test_page.dart';
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

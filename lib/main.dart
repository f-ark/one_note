import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_note/core/app_startup_provider/app_initializer_provider.dart';
import 'package:one_note/core/navigation/app_route_information_parser.dart';
import 'package:one_note/core/navigation/app_router_delegate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initAsync = ref.watch(appInitializerProvider);
    final routerDelegate = AppRouterDelegate(ref);
    final routeInformationParser = AppRouteInformationParser();

    return MaterialApp.router(
      title: 'One Note',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      routerDelegate: routerDelegate,
      routeInformationParser: routeInformationParser,
      backButtonDispatcher: RootBackButtonDispatcher(),
      builder: (context, child) {
        return initAsync.when(
          loading:
              () => const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Yükleniyor... '),
                    ],
                  ),
                ),
              ),

          error:
              (e, st) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Başlatılırken hata: $e'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(appInitializerProvider),
                        child: const Text('Yeniden Dene'),
                      ),
                    ],
                  ),
                ),
              ),
          data: (_) => child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

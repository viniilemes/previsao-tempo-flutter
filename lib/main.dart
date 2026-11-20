import 'package:flutter/material.dart';

import 'screens/pesquisa_page.dart';

void main() => runApp(const PrevisaoApp());

class PrevisaoApp extends StatelessWidget {
  const PrevisaoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Previsão do tempo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.light,
          inputDecorationTheme: const InputDecorationTheme(isDense: true),
        ),
        home: const PesquisaPage(),
      );
}

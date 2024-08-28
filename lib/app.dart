import 'package:flutter/material.dart';
import 'package:map_practice_app/ui/screens/map_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapPage(title: 'Map Animation App',),
    );
  }
}

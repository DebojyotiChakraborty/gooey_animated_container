import 'package:flutter/material.dart';

import 'gooey_menu.dart';
import 'gooey_animated_fab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gooey FAB Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const GooeyFab(),
    );
  }
}

class GooeyFab extends StatelessWidget {
  const GooeyFab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButtonTheme(
      data: theme.floatingActionButtonTheme.copyWith(
        backgroundColor: Colors.black,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        shape: const CircleBorder(),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Gooey FAB')),
        // Full-bleed drag surface for the draggable gooey context menu.
        body: const GooeyMenu(),
        floatingActionButton: const GooeyAnimatedFab(),
      ),
    );
  }
}

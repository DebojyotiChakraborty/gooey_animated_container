import 'package:flutter/material.dart';

import 'gooey_menu.dart';
import 'gooey_menu_legacy.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gooey Menu Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const GooeyFab(),
    );
  }
}

enum _Demo { original, draggable }

class GooeyFab extends StatefulWidget {
  const GooeyFab({super.key});

  @override
  State<GooeyFab> createState() => _GooeyFabState();
}

class _GooeyFabState extends State<GooeyFab> {
  _Demo _demo = _Demo.draggable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gooey Context Menu'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SegmentedButton<_Demo>(
              segments: const [
                ButtonSegment(value: _Demo.original, label: Text('Original')),
                ButtonSegment(value: _Demo.draggable, label: Text('Draggable (new)')),
              ],
              selected: {_demo},
              onSelectionChanged: (s) => setState(() => _demo = s.first),
            ),
          ),
        ),
      ),
      // Rebuild from scratch when switching so each demo starts clean.
      body: switch (_demo) {
        // Original: a fixed, centered inline morph.
        _Demo.original => const Padding(
            padding: EdgeInsets.all(24),
            child: Align(alignment: Alignment.center, child: LegacyGooeyMenu()),
          ),
        // New: full-bleed drag surface.
        _Demo.draggable => const GooeyMenu(),
      },
    );
  }
}

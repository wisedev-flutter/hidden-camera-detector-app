import 'package:flutter/material.dart';

/// Top-level app widget wiring the initial MaterialApp.
class HiddenCameraDetectorApp extends StatelessWidget {
  const HiddenCameraDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hidden Camera Detector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _PlaceholderHome(),
    );
  }
}

/// Temporary placeholder screen until feature work lands in later steps.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hidden Camera Detector')),
      body: const Center(
        child: Text('App scaffold ready for upcoming implementation.'),
      ),
    );
  }
}

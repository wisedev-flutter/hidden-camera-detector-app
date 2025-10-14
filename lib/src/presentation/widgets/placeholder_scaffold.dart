import 'package:flutter/material.dart';

/// Temporary scaffold used while individual feature screens are implemented.
class PlaceholderScaffold extends StatelessWidget {
  const PlaceholderScaffold({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Screen – to be implemented')),
    );
  }
}

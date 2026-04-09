import 'package:flutter/material.dart';

void main() {
  runApp(const SharkTankApp());
}

class SharkTankApp extends StatelessWidget {
  const SharkTankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shark Tank',
      theme: ThemeData.dark(),
      home: const Scaffold(body: Center(child: Text('Shark Tank Simulator'))),
    );
  }
}

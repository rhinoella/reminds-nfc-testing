import 'package:flutter/material.dart';

class DispenseNfc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connecting...')),
      body: const Center(
          child:
              CircularProgressIndicator() // Display loading spinnersage if needed
          ),
    );
  }
}

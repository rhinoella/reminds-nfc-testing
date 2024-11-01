import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminds_flutter/src/services/mqtt_service.dart';
import 'nfc_scan.dart'; // Replace with your actual NFCScan screen

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _connectToMqtt();
  }

  Future<void> _connectToMqtt() async {
    final mqttService = Provider.of<MqttService>(context, listen: false);
    try {
      await mqttService.connect();
      // Navigate to the NFCScan screen upon successful connection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NfcScan()), // Replace with your NFCScan screen
      );
    } catch (e) {
      // Handle connection failure
      setState(() {
        isLoading = false; // Stop loading on failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connecting...')),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Display loading spinner
            : Text(
                'Failed to connect. Please try again.'), // Show error message if needed
      ),
    );
  }
}

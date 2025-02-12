import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminds_flutter/src/dispense/dispense_nfc.dart';
import 'package:reminds_flutter/src/interfaces/api_service_interface.dart';
import 'package:reminds_flutter/src/interfaces/mqtt_service_interface.dart';
import 'package:typed_data/typed_data.dart' as typed;
import 'package:reminds_flutter/src/services/api_service.dart';
import 'package:reminds_flutter/src/services/mqtt_service.dart';
import 'package:reminds_flutter/src/services/nfc_service_old.dart';

class DispenseScreen extends StatefulWidget {
  @override
  _DispenseScreenState createState() => _DispenseScreenState();
}

class _DispenseScreenState extends State<DispenseScreen> {
  bool isReadyForScan = false; // Track NFC scanning state
  late MqttServiceInterface mqttService;
  late ApiServiceInterface apiService;
  NfcService nfcService = NfcService();
  String? medicationId; // Store the received ID from API
  typed.Uint8Buffer? _jsonData;

  @override
  void initState() {
    super.initState();
    mqttService = Provider.of<MqttServiceInterface>(context, listen: false);
    apiService = Provider.of<ApiServiceInterface>(context, listen: false);
    // Call the API function when the widget is initialized
    _registerMedication();
  }

  void handleMqttMessage(typed.Uint8Buffer buffer) {
    _jsonData = buffer;
    setState(() {
      isReadyForScan = true;
    });
  }

  // Make an API call to get an ID
  Future<void> _registerMedication() async {
    try {
      final id = await apiService.registerMedication();

      setState(() {
        medicationId = id;
      });

      mqttService.setMessageRecievedCallback(handleMqttMessage);

      // Now, call the MQTT service with the received ID
      mqttService.publishId(id);
    } catch (e) {
      setState(() {
        isReadyForScan = false;
      });
      print("Error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dispense Medication',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Center(
          child: isReadyForScan
              ? DispenseNfc()
              : const CircularProgressIndicator() // Show loading while waiting for API response
          ),
    );
  }
}

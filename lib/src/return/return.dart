import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:reminds_flutter/src/interfaces/api_service_interface.dart';
import 'package:reminds_flutter/src/interfaces/mqtt_service_interface.dart';
import 'package:reminds_flutter/src/interfaces/nfc_service_interface.dart';
import 'package:reminds_flutter/src/services/nfc_service.dart';
import 'package:typed_data/typed_data.dart' as typed;
import 'package:flutter/services.dart';

class ReturnScreen extends StatefulWidget {
  @override
  _ReturnScreenState createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  bool isReadyForScan = false; // Track NFC scanning state
  late MqttServiceInterface mqttService;
  late ApiServiceInterface apiService;
  NfcServiceInterface nfcService = NfcService();
  String? medicationId;

  @override
  void initState() {
    super.initState();
    mqttService = Provider.of<MqttServiceInterface>(context, listen: false);
    apiService = Provider.of<ApiServiceInterface>(context, listen: false);
    _readNfc();
  }

  Future<void> _readNfc({String? msg = "Place package on reader."}) async {
    NfcReadData? nfcData;

    NfcManager.instance.startSession(
        alertMessage: msg,
        pollingOptions: {NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          try {
            nfcData = await nfcService.cycleNfc(tag);
            await NfcManager.instance.stopSession(alertMessage: "Success");
          } catch (e) {
            await NfcManager.instance
                .stopSession(errorMessage: "Return Failed: $e");
          }
        });

    if (nfcData != null) {
      var medicationId = int.parse(nfcData!.configId.toString());

      Uint8List sensorData = Uint8List.fromList(
          nfcData!.pageData.values.expand((x) => x).toList());

      typed.Uint8Buffer sensorBuffer = typed.Uint8Buffer();
      sensorBuffer.addAll(sensorData);

      await apiService.returnMedication(medicationId, sensorData);
      mqttService.publishData(sensorBuffer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Return Medication',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
          child: Padding(
        padding:
            EdgeInsets.symmetric(vertical: 32), // Adds padding around buttons
        child: Column(
          children: [
            Text("Follow device instructions."),
          ],
        ),
      )),
    );
  }
}

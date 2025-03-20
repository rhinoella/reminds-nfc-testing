import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:typed_data/typed_data.dart' as typed;

import 'package:reminds_flutter/src/interfaces/nfc_service_interface.dart';
import 'package:reminds_flutter/src/services/nfc_service.dart';

class DispenceNfc extends StatefulWidget {
  final typed.Uint8Buffer initData;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;

  const DispenceNfc(
      {Key? key,
      required this.initData,
      required this.onSuccess,
      required this.onFailure})
      : super(key: key);
  @override
  _DispenseNfcState createState() => _DispenseNfcState();
}

class _DispenseNfcState extends State<DispenceNfc> {
  late NfcServiceInterface nfcService;
  int retryCount = 0;
  final int maxRetries = 3;

  @override
  @override
  void initState() {
    super.initState();
    nfcService = NfcService();
    _startNfcSession();
  }

  void _startNfcSession({String? msg = "Place package on reader."}) {
    NfcManager.instance.startSession(
        alertMessage: msg,
        pollingOptions: {NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          try {
            print('${tag.data}');
            // Get the NDEF instance from the tag.
            final payload = Uint8List.fromList(widget.initData.toList());
            await nfcService.writeJson(tag, payload);
            await NfcManager.instance.stopSession(alertMessage: "Success");
            widget.onSuccess();
            retryCount = 0; // Reset retry count after success
          } catch (e) {
            await NfcManager.instance
                .stopSession(errorMessage: "Dispense Failed: $e");
            onFailure();
          }
        });
  }

  Future<void> onFailure() async {
    if (retryCount < maxRetries) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        _startNfcSession(
            msg: "Retrying, hold the tag securely against the device.");
        retryCount++;
      }
    } else {
      widget.onFailure();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding:
          EdgeInsets.symmetric(vertical: 32), // Adds padding around buttons
      child: Column(
        children: [
          Text("Follow device instructions."),
        ],
      ),
    );
  }
}

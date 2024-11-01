// nfc_service.dart
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  Future<void> startNfcScan() async {
    // Start the NFC scan
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // Handle the discovered NFC tag
      print('NFC Tag Discovered: ${tag.data}');
      // Stop the session after tag discovery
      await NfcManager.instance.stopSession();
    });
  }

  Future<void> stopNfcScan() async {
    // Stop the NFC session if it is running
    await NfcManager.instance.stopSession();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminds_flutter/src/services/nfc_service.dart';

class NfcScan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          GestureDetector(
            onTap: () async {
              // Get the NfcService from the provider
              final nfcService =
                  Provider.of<NfcService>(context, listen: false);
              // Start the NFC scan
              await nfcService.startNfcScan();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.purple.shade500,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "Scan",
                style: TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

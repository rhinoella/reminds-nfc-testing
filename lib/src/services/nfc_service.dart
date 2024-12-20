import 'package:nfc_manager/nfc_manager.dart';
import 'package:ndef/ndef.dart';
import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/platform_tags.dart';

class NfcService {
  Future<String?> readNfc() async {
    print("Searcing for NFC");
    NfcManager.instance.startSession(
      pollingOptions: <NfcPollingOption>{NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        try {
          print('NFC Tag Detected: ${tag.data}');
          // Do something with an NfcTag instance.
          Iso15693? isoTag = Iso15693.from(tag);

          if (isoTag == null) {
            throw Exception("Tag is not compatible with iso");
          }

          final res = await isoTag.readMultipleBlocks(
              requestFlags: <Iso15693RequestFlag>{
                Iso15693RequestFlag.highDataRate
              },
              blockNumber: 0,
              numberOfBlocks: 64);

          print(res);

          await NfcManager.instance
              .stopSession(alertMessage: "Read Successful");
        } catch (e) {
          print(e);
          await NfcManager.instance
              .stopSession(alertMessage: "Read Failed: $e");
        }
      },
      alertMessage: "Place a tag on the reader",
    );
  }

  Future<void> writeNfc() async {
    if (!(await NfcManager.instance.isAvailable())) {
      throw Exception("Unavaliable");
    }
    print("Searcing for NFC");
    NfcManager.instance.startSession(
      pollingOptions: <NfcPollingOption>{NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        try {
          print('NFC Tag Detected: ${tag.data}');
          // Do something with an NfcTag instance.
          Iso15693? isoTag = Iso15693.from(tag);

          if (isoTag == null) {
            throw Exception("Tag is not compatible with iso");
          }

          List<Uint8List> blockBytes = createSequentialDataBlocks(0, 4);
          print(blockBytes.length);

          await isoTag.writeMultipleBlocks(requestFlags: <Iso15693RequestFlag>{
            Iso15693RequestFlag.highDataRate
          }, blockNumber: 0, numberOfBlocks: 4, dataBlocks: blockBytes);

          await NfcManager.instance
              .stopSession(alertMessage: "Write Successful");
        } catch (e) {
          print(e);
          await NfcManager.instance
              .stopSession(alertMessage: "Write Failed: $e");
        }
      },
      alertMessage: "Place a tag on the reader",
    );
  }

  Future<void> fillNfc() async {
    if (!(await NfcManager.instance.isAvailable())) {
      throw Exception("Unavailable");
    }
    print("Searching for NFC");

    NfcManager.instance.startSession(
      pollingOptions: <NfcPollingOption>{NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        try {
          print('NFC Tag Detected: ${tag.data}');
          // Do something with an NfcTag instance.
          Iso15693? isoTag = Iso15693.from(tag);

          if (isoTag == null) {
            throw Exception("Tag is not compatible with iso");
          }

          // Define the total number of blocks
          int totalBlocks = 256;

          // Write the blocks in batches of 4
          for (int blockNumber = 0;
              blockNumber < totalBlocks;
              blockNumber += 4) {
            int batchSize = (blockNumber + 4 <= totalBlocks)
                ? 4
                : totalBlocks - blockNumber;

            // Create the sequential data blocks
            List<Uint8List> blockBytes =
                createSequentialDataBlocks(blockNumber, batchSize);
            print(
                'Writing blocks from $blockNumber to ${blockNumber + batchSize - 1}');

            // Write the batch of 4 blocks
            await isoTag.writeMultipleBlocks(
              requestFlags: <Iso15693RequestFlag>{
                Iso15693RequestFlag.highDataRate
              },
              blockNumber: blockNumber,
              numberOfBlocks: batchSize,
              dataBlocks: blockBytes,
            );
          }

          await NfcManager.instance
              .stopSession(alertMessage: "Write Successful");
        } catch (e) {
          print(e);
          await NfcManager.instance
              .stopSession(alertMessage: "Write Failed: $e");
        }
      },
      alertMessage: "Place a tag on the reader",
    );
  }

  Uint8List hexToBytes(String hex) {
    // Ensure the string has an even length
    if (hex.length % 2 != 0) {
      hex = '0$hex';
    }

    // Convert hex to bytes
    return Uint8List.fromList(List.generate(
      hex.length ~/ 2,
      (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
    ));
  }

  List<String> uint8ListToHexList(Uint8List bytes) {
    List<String> hexList = [];

    for (int i = 0; i < bytes.length; i += 4) {
      List<int> block =
          bytes.sublist(i, (i + 4 > bytes.length) ? bytes.length : i + 4);
      String formattedBlock = block
          .map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}')
          .join(', ');

      hexList.add(formattedBlock);
    }

    return hexList;
  }

  List<Uint8List> createSequentialDataBlocks(int startFrom, int blockCount) {
    List<Uint8List> dataBlocks = [];

    // Generate data for the specified number of blocks
    for (int i = startFrom; i < startFrom + blockCount; i++) {
      // Create a block of 4 bytes, using i to generate sequential data
      Uint8List block = Uint8List.fromList([
        (i * 4 + 0) % 256, // First byte
        (i * 4 + 1) % 256, // Second byte
        (i * 4 + 2) % 256, // Third byte
        (i * 4 + 3) % 256, // Fourth byte
      ]);
      dataBlocks.add(block);
    }

    return dataBlocks;
  }

  Future<void> cycleNfc() async {}
}

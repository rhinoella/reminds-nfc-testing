import 'dart:ffi';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:ndef/ndef.dart';
import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/platform_tags.dart';

// Amount of blocks of 4 bytes in an 8K-byte nfc
const totalBlocks = 2048;
const totalBytes = 8192;

class NfcService {
  Map<int, Uint8List> blockData = {};

  Future<Uint8List?> readMemory(Iso15693 isoTag, int targetBlock) async {
    final res = await isoTag.readMultipleBlocks(
        requestFlags: <Iso15693RequestFlag>{Iso15693RequestFlag.highDataRate},
        blockNumber: 0,
        numberOfBlocks: 64);

    if (res.length != 64) {
      throw Exception("Error reading tag");
    }

    final blockNumber = res[0].first;

    if (blockNumber == targetBlock) {
      Uint8List flatList = Uint8List.fromList([
        ...res[0].sublist(1),
        ...res.skip(1).expand((list) => list),
      ]);

      return flatList;
    }

    return null;
  }

  Future<void> writeBlockCommand(Iso15693 isoTag, int blockNumber) async {
    isoTag.writeSingleBlock(
        requestFlags: <Iso15693RequestFlag>{Iso15693RequestFlag.highDataRate},
        blockNumber: 0,
        dataBlock: Uint8List.fromList([blockNumber, 0, 0, 0]));
  }

  Future<String?> readNfc() async {
    print("Searching for NFC");
    NfcManager.instance.startSession(
      pollingOptions: <NfcPollingOption>{NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        try {
          print('NFC Tag Detected: ${tag}');
          // Do something with an NfcTag instance.
          Iso15693? isoTag = Iso15693.from(tag);

          if (isoTag == null) {
            throw Exception("Tag is not compatible with ISO 15693");
          }

          List<Uint8List> fullData = [];
          int blockNumber = 0;
          const int numberOfBlocks = 64;
          const int totalBlocks = 2047;

          while (blockNumber < totalBlocks) {
            try {
              // Read the next chunk of blocks
              var res = await isoTag.extendedReadMultipleBlocks(
                requestFlags: <Iso15693RequestFlag>{
                  Iso15693RequestFlag.highDataRate
                },
                blockNumber: blockNumber,
                numberOfBlocks: numberOfBlocks,
              );

              if (res != null) {
                // Append the read data to the fullData list
                fullData.addAll(res);
                print(
                    'Read blocks: $blockNumber to ${blockNumber + numberOfBlocks - 1}');
              }

              blockNumber += numberOfBlocks;
            } catch (e) {
              print(
                  'Error reading blocks $blockNumber to ${blockNumber + numberOfBlocks - 1}: $e');
              break;
            }
          }

          // Do something with the full data, like process or store it.
          print('Full data read: $fullData');
          await NfcManager.instance
              .stopSession(alertMessage: "Read Successful");
        } catch (e) {
          print(e);
          await NfcManager.instance
              .stopSession(alertMessage: "Read Failed: $e");

          if (e is PlatformException) {
            print(e.message);
          }
        }
      },
      alertMessage: "Place a tag on the reader",
    );

    return "Read success";
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
          print('NFC Tag Detected: ${tag}');
          // Do something with an NfcTag instance.
          Iso15693? isoTag = Iso15693.from(tag);

          if (isoTag == null) {
            throw Exception("Tag is not compatible with iso");
          }

          List<Uint8List> blockBytes = createSequentialDataBlocks(0, 4);
          print(blockBytes.length);

          /*await isoTag.writeMultipleBlocks(requestFlags: <Iso15693RequestFlag>{
            Iso15693RequestFlag.highDataRate
          }, blockNumber: 0, numberOfBlocks: 4, dataBlocks: blockBytes);*/

          final res1 = await isoTag.extendedWriteSingleBlock(
              requestFlags: <Iso15693RequestFlag>{
                Iso15693RequestFlag.highDataRate
              },
              blockNumber: 260,
              dataBlock: Uint8List.fromList([6, 7, 8, 9]));

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
      throw Exception("NFC Unavailable");
    }
    print("Starting NFC write process");

    int totalBlocks = 2048;
    int blocksPerSession = 256;
    int sessionIndex = 0;

    print("Starting session ${sessionIndex + 1}");

    await NfcManager.instance.startSession(
      pollingOptions: <NfcPollingOption>{NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        try {
          Iso15693? isoTag = Iso15693.from(tag);
          if (isoTag == null) {
            throw Exception("Tag is not compatible with ISO 15693");
          }

          int startBlock = sessionIndex * blocksPerSession;
          print(
              "Writing session ${sessionIndex + 1}: Blocks $startBlock to ${startBlock + blocksPerSession - 1}");

          for (int blockNumber = startBlock;
              blockNumber < startBlock + blocksPerSession;
              blockNumber += 4) {
            int batchSize = (blockNumber + 4 <= startBlock + blocksPerSession)
                ? 4
                : (startBlock + blocksPerSession) - blockNumber;

            List<Uint8List> blockBytes = List.generate(
                batchSize,
                (_) => Uint8List.fromList(
                    [sessionIndex, sessionIndex, sessionIndex, sessionIndex]));
            print(
                'Writing blocks from $blockNumber to ${blockNumber + batchSize - 1}');

            await isoTag.extendedWriteMultipleBlocks(
              requestFlags: <Iso15693RequestFlag>{
                Iso15693RequestFlag.highDataRate
              },
              blockNumber: blockNumber,
              numberOfBlocks: batchSize,
              dataBlocks: blockBytes,
            );
          }

          final res = await isoTag.extendedReadMultipleBlocks(
              requestFlags: <Iso15693RequestFlag>{
                Iso15693RequestFlag.highDataRate
              },
              blockNumber: 256 * sessionIndex,
              numberOfBlocks: 64);

          print(res);

          await NfcManager.instance.stopSession(
              alertMessage: "Session ${sessionIndex + 1} Write Successful");
          print("Session ${sessionIndex + 1} complete");
        } catch (e) {
          print("Error in session ${sessionIndex + 1}: $e");
          await NfcManager.instance
              .stopSession(alertMessage: "Write Failed: $e");
        }
      },
      alertMessage: "Place a tag on the reader for session ${sessionIndex + 1}",
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

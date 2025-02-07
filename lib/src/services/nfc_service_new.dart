import 'dart:ffi';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:ndef/ndef.dart';
import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/platform_tags.dart';

class NfcService {
  static const int masterCommand = 0x01;
  static const int slaveCommand = 0x02;

  Map<int, Uint8List> blockData = {};
  int currentBlock = 1;

  Future<List<int>> readCommandBlock(Iso15693 isoTag) async {
     final firstBlock = await isoTag.readSingleBlock(
        requestFlags: <Iso15693RequestFlag>{Iso15693RequestFlag.highDataRate},
        blockNumber: 0
      );

       int commandBlock = firstBlock.first;

    // Extract the command (higher 4 bits)
    int command = (commandBlock >> 4) & 0x0F;

    // Extract the block number (lower 4 bits)
    int block = commandBlock & 0x0F;

    // Return both values in a map
    return [command, block];
  }

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
    int commandBlock = (masterCommand << 4) | currentBlock;

    isoTag.writeSingleBlock(
        requestFlags: <Iso15693RequestFlag>{Iso15693RequestFlag.highDataRate},
        blockNumber: 0,
        dataBlock: Uint8List.fromList([commandBlock, 0, 0, 0]));
  }

  Future<void> cycleNfc() async {
        NfcManager.instance.startSession(
      pollingOptions: <NfcPollingOption>{NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        try {
          Iso15693? isoTag = Iso15693.from(tag);

          if (isoTag == null) {
            throw Exception("Tag is not compatible with iso");
          }

          for (currentBlock; currentBlock < 5; currentBlock++) {
            await writeBlockCommand(isoTag, currentBlock);
            int commandBlock = 0;

            while (commandBlock != slaveCommand) {
              final commandRead = await readCommandBlock(isoTag);
              commandBlock = commandRead.first;

              if (commandBlock == slaveCommand) {
                break;
              }
            }

            await readB
          }
        } catch (e) {
          print('e');
        }
        });
  }
}

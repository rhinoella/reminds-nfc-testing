import 'dart:ffi';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:ndef/ndef.dart';
import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:reminds_flutter/src/interfaces/nfc_service_interface.dart';

class NfcService implements NfcServiceInterface {
  static const int masterCommand = 0x01;
  static const int slaveCommand = 0x02;
  static const totalBlocks = 2048;
  static const totalBytes = 8192;

  Map<int, Uint8List> pageData = {};
  int currentBlock = 1;

  Future<List<int>> readCommandBlock(Iso15693 isoTag) async {
    final firstBlock = await isoTag.readSingleBlock(
        requestFlags: <Iso15693RequestFlag>{Iso15693RequestFlag.highDataRate},
        blockNumber: 0);

    int commandBlock = firstBlock.first;

    // Extract the command (higher 4 bits)
    int command = (commandBlock >> 4) & 0x0F;

    // Extract the page number (lower 4 bits)
    int page = commandBlock & 0x0F;

    // Return both values in a map
    return [command, page];
  }

  Future<void> writeBlockCommand(Iso15693 isoTag, int blockNumber) async {
    int commandBlock = (masterCommand << 4) | currentBlock;

    isoTag.writeSingleBlock(
        requestFlags: <Iso15693RequestFlag>{Iso15693RequestFlag.highDataRate},
        blockNumber: 0,
        dataBlock: Uint8List.fromList([commandBlock, 0, 0, 0]));
  }

  Future<Uint8List> readFullPage(Iso15693 isoTag) async {
    List<int> fullData = [];
    const int numberOfBlocks = 64;

    // Read first 64 blocks and omit command
    var res = await read64Blocks(isoTag, 0);

    fullData
        .addAll([...res[0].sublist(1), ...res.skip(1).expand((list) => list)]);

    for (var blockNumber = 1;
        blockNumber < totalBlocks;
        blockNumber += numberOfBlocks) {
      // Read the next chunk of blocks
      var res = await read64Blocks(isoTag, blockNumber);

      fullData.addAll([...res.expand((list) => list)]);
    }

    return Uint8List.fromList(fullData);
  }

  Future<List<Uint8List>> read64Blocks(Iso15693 isoTag, int targetBlock) async {
    final res = await isoTag.readMultipleBlocks(
        requestFlags: <Iso15693RequestFlag>{Iso15693RequestFlag.highDataRate},
        blockNumber: targetBlock,
        numberOfBlocks: 64);

    if (res.length != 64) {
      throw Exception("Error reading tag");
    }

    return res;
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

            for (var currentPage = 0; currentPage < 5; currentPage++) {
              await writeBlockCommand(isoTag, currentBlock);
              int commandBlock = 0;

              /*while (commandBlock != slaveCommand) {
              final commandRead = await readCommandBlock(isoTag);
              commandBlock = commandRead.first;

              if (commandBlock == slaveCommand && commandRead[1] == currentPage) {
                break;
              }
            }*/

              final result = await readFullPage(isoTag);
              pageData[currentPage] = result;
            }

            print(pageData);
          } catch (e) {
            print('e');
          }
        });
  }
}

import 'package:nfc_manager/nfc_manager.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:reminds_flutter/src/interfaces/nfc_service_interface.dart';

class NfcService implements NfcServiceInterface {
  static const int slaveCommand = 0x02;
  static const totalBlocks = 2048;
  static const totalBytes = 8192;

  @override
  Future<List<int>> readCommandBlock(Iso15693 isoTag) async {
    final commandBlock = await isoTag.readSingleBlock(
      requestFlags: <Iso15693RequestFlag>{Iso15693RequestFlag.highDataRate},
      blockNumber: 44,
    );

    int command = commandBlock[1]; // 0x02 = read command
    int page = commandBlock[2]; // page number

    return [command, page];
  }

  @override
  Future<void> writeBlockCommand(Iso15693 isoTag, int currentPage) async {
    await isoTag.writeSingleBlock(
      requestFlags: <Iso15693RequestFlag>{Iso15693RequestFlag.highDataRate},
      blockNumber: 44,
      dataBlock: Uint8List.fromList([0xFA, 0x02, currentPage]),
    );
  }

  @override
  Future<Uint8List> readConfigId(Iso15693 isoTag) async {
    final blocks = await isoTag.readMultipleBlocks(
      requestFlags: <Iso15693RequestFlag>{Iso15693RequestFlag.highDataRate},
      blockNumber: 15,
      numberOfBlocks: 4,
    );

    final flattenedBytes = blocks.expand((Uint8List block) => block).toList();
    return Uint8List.fromList(flattenedBytes);
  }

  @override
  Future<void> writeJson(NfcTag tag, Uint8List payload) async {
    final ndef = Ndef.from(tag);

    if (ndef == null) {
      throw Exception("Tag is not NDEF compatible");
    }
    if (!ndef.isWritable) {
      throw Exception("Tag is not writable");
    }

    final message = NdefMessage([
      NdefRecord.createMime(
        'application/json',
        payload,
      ),
    ]);
    await ndef.write(message);
  }

  @override
  Future<NfcReadData> cycleNfc(NfcTag tag) async {
    Map<int, Uint8List> pageData = {};

    final isoTag = Iso15693.from(tag);
    final ndef = Ndef.from(tag);

    if (ndef == null || isoTag == null) {
      throw Exception("Tag is not compatible.");
    }

    final configId = await readConfigId(isoTag);

    final message = await ndef.read();

    final allPayloads = message.records
        .map((record) => record.payload)
        .expand((payload) => payload)
        .toList();
    final combinedPayload = Uint8List.fromList(allPayloads);

    pageData[0] = combinedPayload;

    for (var currentPage = 1; currentPage < 6; currentPage++) {
      await writeBlockCommand(isoTag, currentPage);
      int commandBlock = 0;
      const maxIterations = 100;
      int iterations = 0;

      while (commandBlock != slaveCommand) {
        final commandRead = await readCommandBlock(isoTag);
        commandBlock = commandRead.first;

        if (commandBlock == slaveCommand && commandRead[1] == currentPage) {
          break;
        }

        iterations++;
        if (iterations > maxIterations) {
          throw Exception("Max iterations reached");
        }
      }

      final message = await ndef.read();

      final allPayloads = message.records
          .map((record) => record.payload)
          .expand((payload) => payload)
          .toList();
      final combinedPayload = Uint8List.fromList(allPayloads);
      pageData[currentPage] = combinedPayload;
    }

    return NfcReadData(configId: configId, pageData: pageData);
  }
}

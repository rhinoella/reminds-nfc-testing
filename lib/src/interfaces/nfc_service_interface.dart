import 'dart:async';
import 'package:flutter/services.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcReadData {
  final Uint8List configId;
  final Map<int, Uint8List> pageData;

  NfcReadData({required this.configId, required this.pageData});
}

abstract class NfcServiceInterface {
  static const int masterCommand = 0x01;
  static const int slaveCommand = 0x02;
  static const totalBlocks = 2048;
  static const totalBytes = 8192;

  Future<List<int>> readCommandBlock(Iso15693 isoTag);

  Future<void> writeBlockCommand(Iso15693 isoTag, int currentPage);

  Future<Uint8List> readConfigId(Iso15693 isoTag);

  Future<void> writeJson(NfcTag tag, Uint8List payload);

  Future<NfcReadData> cycleNfc(NfcTag tag);
}

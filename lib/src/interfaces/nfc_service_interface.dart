import 'dart:ffi';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:ndef/ndef.dart';
import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/platform_tags.dart';

abstract class NfcServiceInterface {
  static const int masterCommand = 0x01;
  static const int slaveCommand = 0x02;
  static const totalBlocks = 2048;
  static const totalBytes = 8192;

  Map<int, Uint8List> pageData = {};
  int currentBlock = 1;

  Future<List<int>> readCommandBlock(Iso15693 isoTag);

  Future<void> writeBlockCommand(Iso15693 isoTag, int blockNumber);

  Future<Uint8List> readFullPage(Iso15693 isoTag);

  Future<List<Uint8List>> read64Blocks(Iso15693 isoTag, int targetBlock);

  Future<void> cycleNfc();
}

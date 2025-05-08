import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminds_flutter/config.dart';
import 'package:reminds_flutter/src/dispense/dispense.dart';
import 'package:reminds_flutter/src/main/main_bloc.dart';
import 'package:reminds_flutter/src/return/return.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:ndef/ndef.dart';
import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/platform_tags.dart';

class RemindsMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RemindsBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ReMINDS',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.purple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0), // Adds padding around buttons
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 40),
                  child: SizedBox(
                    width: double.infinity, // Make the button fill width
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DispenseScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout,
                              color: Colors.purple, size: 30), // Dispense icon
                          SizedBox(width: 10),
                          Text(
                            "Dispense",
                            style:
                                TextStyle(fontSize: 20, color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  child: SizedBox(
                    width: double.infinity, // Make the button fill width
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReturnScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login,
                              color: Colors.purple, size: 30), // Return icon
                          SizedBox(width: 10),
                          Text(
                            "Return",
                            style:
                                TextStyle(fontSize: 20, color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (mode == "dev")
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 40),
                    child: SizedBox(
                        width: double.infinity,
                        child: Column(children: [
                          ElevatedButton(
                            onPressed: () async {
                              // Check NFC availability.
                              if (!(await NfcManager.instance.isAvailable())) {
                                throw Exception("NFC Unavailable");
                              }
                              print("Starting NFC write process");

                              // Session parameters.
                              int totalBlocks = 2048;
                              int blocksPerSession = 256;
                              int sessionIndex = 7;
                              int startAt = 12;
                              int blockSize =
                                  4; // Each NFC block is assumed to be 4 bytes.

                              print("Starting session ${sessionIndex + 1}");

                              // Start NFC session.
                              await NfcManager.instance.startSession(
                                pollingOptions: <NfcPollingOption>{
                                  NfcPollingOption.iso15693,
                                },
                                onDiscovered: (NfcTag tag) async {
                                  try {
                                    // Check that the tag is NDEF compatible.
                                    final ndef = Ndef.from(tag);
                                    if (ndef == null) {
                                      throw Exception(
                                          "Tag is not NDEF compatible");
                                    }
                                    if (!ndef.isWritable) {
                                      throw Exception("Tag is not writable");
                                    }

                                    // Load the binary asset.
                                    /*final ByteData byteData = await rootBundle.load(
                                        'assets/data/dataActualFlashSett-4.bin');
                                    final Uint8List fileBytes =
                                        byteData.buffer.asUint8List();*/

                                    final fileBytes = Uint8List.fromList(
                                        [1, 1, 1, 1, 1, 1, 1, 2]);

                                    // Calculate available payload size.
                                    const int totalMemory = 8192;
                                    const int reservedBytes = 8000;
                                    const String mimeType =
                                        "application/octet-stream";
                                    // Estimated NDEF overhead:
                                    // 1 byte header + 1 byte type length + 4 bytes payload length + mimeType length
                                    final int ndefOverhead =
                                        1 + 1 + 4 + mimeType.length;
                                    final int maxPayload = totalMemory -
                                        reservedBytes -
                                        ndefOverhead;

                                    // Trim the payload if it exceeds the max allowed.
                                    Uint8List trimmedPayload;
                                    if (fileBytes.length > maxPayload) {
                                      trimmedPayload =
                                          fileBytes.sublist(0, maxPayload);
                                      print(
                                          "Payload trimmed from ${fileBytes.length} to $maxPayload bytes");
                                    } else {
                                      trimmedPayload = fileBytes;
                                    }

                                    // Create an NDEF record with MIME type and the trimmed payload.
                                    final NdefRecord record =
                                        NdefRecord.createMime(
                                      mimeType,
                                      trimmedPayload,
                                    );

                                    // Create the NDEF message.
                                    final NdefMessage message =
                                        NdefMessage([record]);

                                    // Write the NDEF message to the tag.
                                    await ndef.write(message);
                                    print("NDEF message written successfully!");
                                  } catch (e) {
                                    print("Error during NDEF write: $e");
                                  } finally {
                                    // Always stop the NFC session.
                                    NfcManager.instance.stopSession();
                                  }
                                },
                              );

                              /*const NDEF_PRE = [
                                0x03,
                                0x22,
                                0xD2,
                                0x18,
                                0x08, // This is payload length
                                0x61,
                                0x70,
                                0x70,
                                0x6C,
                                0x69,
                                0x63,
                                0x61,
                                0x74,
                                0x69,
                                0x6F,
                                0x6E,
                                0x2F,
                                0x6F,
                                0x63,
                                0x74,
                                0x65,
                                0x74,
                                0x2D,
                                0x73,
                                0x74,
                                0x72,
                                0x65,
                                0x61,
                                0x6D,
                                0x73,
                                0x74,
                                0x72,
                                0x65,
                                0x61,
                                0x6D
                              ]; // End message with FE
//"application/on/on/octet-stream."
                              const bytesToWrite = [
                                [0x03, 0x1B, 0xD2, 0x18],
                                [
                                  0x08, // This is payload length
                                  0x61,
                                  0x70,
                                  0x70
                                ],
                                [0x6C, 0x69, 0x63, 0x61],
                                [0x74, 0x69, 0x6F, 0x6E],
                                [0x2F, 0x6F, 0x63, 0x74],
                                [0x65, 0x74, 0x2D, 0x73],
                                [0x74, 0x72, 0x65, 0x61],
                                [0x6D, 1, 1, 1],
                                [
                                  1,
                                  1,
                                  1,
                                  1,
                                ],
                                [2, 0xFE, 0, 0]
                              ];*.

                              // Start NFC session.
                              await NfcManager.instance.startSession(
                                pollingOptions: <NfcPollingOption>{
                                  NfcPollingOption.iso15693,
                                },
                                onDiscovered: (NfcTag tag) async {
                                  try {
                                    // Verify that the tag supports ISO15693.
                                    Iso15693? isoTag = Iso15693.from(tag);
                                    if (isoTag == null) {
                                      throw Exception(
                                          "Tag is not compatible with ISO 15693");
                                    }

                                    // Load the binary asset.
                                    /*final ByteData byteData = await rootBundle.load(
                                        'assets/data/dataActualFlashSett-4.bin');
                                    final Uint8List fileBytes =
                                        byteData.buffer.asUint8List();*/

                                    final List<Uint8List> batches = bytesToWrite
                                        .map((b) => Uint8List.fromList(b))
                                        .toList();

                                    int startBlock = 2;
                                    print(
                                        "Writing session ${sessionIndex + 1}: Blocks $startBlock to ${startBlock + blocksPerSession - 1}");

                                    // Write the data blocks to the tag.
                                    // We are writing up to 4 blocks at a time.
                                    int currentBatchIndex = 0;
                                    while (currentBatchIndex < batches.length &&
                                        (startBlock + currentBatchIndex) <
                                            (startBlock + blocksPerSession)) {
                                      // Calculate the number of blocks remaining in this session.
                                      int blocksRemainingInSession =
                                          (startBlock + blocksPerSession) -
                                              (startBlock + currentBatchIndex);
                                      int blocksRemainingInFile =
                                          batches.length - currentBatchIndex;
                                      int blocksToWrite =
                                          blocksRemainingInFile >= 4
                                              ? 4
                                              : blocksRemainingInFile;
                                      // Do not exceed the session's allowed block count.
                                      if (blocksToWrite >
                                          blocksRemainingInSession) {
                                        blocksToWrite =
                                            blocksRemainingInSession;
                                      }

                                      // Extract the current group of blocks.
                                      final List<Uint8List> blockData =
                                          batches.sublist(
                                              currentBatchIndex,
                                              currentBatchIndex +
                                                  blocksToWrite);
                                      print(
                                          "Writing blocks from ${startBlock + currentBatchIndex} to ${startBlock + currentBatchIndex + blocksToWrite - 1}");

                                      // Write these blocks using extendedWriteMultipleBlocks.
                                      await isoTag.extendedWriteMultipleBlocks(
                                        requestFlags: <Iso15693RequestFlag>{
                                          Iso15693RequestFlag.highDataRate,
                                        },
                                        blockNumber:
                                            startBlock + currentBatchIndex,
                                        numberOfBlocks: blocksToWrite,
                                        dataBlocks: blockData,
                                      );
                                      currentBatchIndex += blocksToWrite;
                                    }
                                  } catch (e) {
                                    print("Error during NFC write: $e");
                                  } finally {
                                    // Always stop the NFC session.
                                    NfcManager.instance.stopSession();
                                  }
                                },
                              );*/
                            },
                            child: Text("Write to NFC"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await NfcManager.instance.startSession(
                                pollingOptions: <NfcPollingOption>{
                                  NfcPollingOption.iso15693
                                },
                                onDiscovered: (NfcTag tag) async {
                                  try {
                                    Iso15693? isoTag = Iso15693.from(tag);
                                    if (isoTag == null) {
                                      throw Exception(
                                          "Tag is not compatible with ISO 15693");
                                    }

                                    final ndef = Ndef.from(tag);

                                    if (ndef == null) {
                                      throw Exception("NDEF is null");
                                    }

                                    final message = await ndef.read();

                                    final allPayloads = message.records
                                        .map((record) => record.payload)
                                        .expand((payload) => payload)
                                        .toList();
                                    final combinedPayload =
                                        Uint8List.fromList(allPayloads);

                                    print(combinedPayload);
                                    await NfcManager.instance
                                        .stopSession(alertMessage: "Success");
                                  } catch (e) {
                                    print("Error in session: $e");
                                  }
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text("Read NFC"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              NfcManager.instance.startSession(
                                  pollingOptions: {NfcPollingOption.iso15693},
                                  onDiscovered: (NfcTag tag) async {
                                    try {
                                      print('${tag.data}');
                                      // Get the NDEF instance from the tag.
                                      final isoTag = Iso15693.from(tag);

                                      if (isoTag == null) {
                                        await NfcManager.instance
                                            .stopSession(alertMessage: "Fail");
                                      }

                                      var data = [0xE2, 0x40, 0x00, 0x01];
                                      var dat = [0x00, 0x00, 0x04, 0x00];

                                      Uint8List data1 =
                                          Uint8List.fromList(data);
                                      Uint8List data2 = Uint8List.fromList(dat);

                                      var dataa = [data1, data2];

                                      await isoTag?.writeMultipleBlocks(
                                          requestFlags: <Iso15693RequestFlag>{
                                            Iso15693RequestFlag.highDataRate
                                          },
                                          blockNumber: 0,
                                          numberOfBlocks: 2,
                                          dataBlocks: dataa);

                                      await NfcManager.instance
                                          .stopSession(alertMessage: "Success");
                                      0; // Reset retry count after success
                                    } catch (e) {
                                      await NfcManager.instance.stopSession(
                                          errorMessage: "Dispense Failed: $e");
                                    }
                                  });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text("Forma NDEF"),
                          ),
                        ])),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

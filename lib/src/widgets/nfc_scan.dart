import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart';
import 'package:reminds_flutter/src/utils/testNfcData.dart';
import '../nfc/nfc_bloc.dart';
import '../nfc/nfc_event.dart';
import '../nfc/nfc_state.dart';
import '../services/nfc_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NfcScan extends StatefulWidget {
  @override
  _NfcScanState createState() => _NfcScanState();
}

class _NfcScanState extends State<NfcScan> with SingleTickerProviderStateMixin {
  String _platformVersion = '';
  NFCAvailability _availability = NFCAvailability.not_supported;
  NFCTag? _tag;
  String _result = "";
  String _writeResult = "";
  late TabController _tabController;
  final List<NDEFRecord> _records = [testRecord];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> initPlatformState() async {
    NFCAvailability availability;
    try {
      availability = await FlutterNfcKit.nfcAvailability;
    } on PlatformException {
      availability = NFCAvailability.not_supported;
    }

    if (!mounted) return;

    setState(() {
      _availability = availability;
    });
  }

  Future<void> startPolling() async {
    try {
      NFCTag tag = await FlutterNfcKit.poll();
      print(jsonEncode(tag));

      setState(() {
        _result = "";
      });

      await FlutterNfcKit.setIosAlertMessage("Working on it...");
      if (tag.ndefAvailable ?? false) {
        for (var record
            in await FlutterNfcKit.readNDEFRawRecords(cached: false)) {
          print(jsonEncode(record).toString());
          setState(() {
            _result = record.payload;
          });
        }
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      await FlutterNfcKit.finish(iosAlertMessage: "Finished!");
    }
  }

  Future<void> startWriting() async {
    if (_records.isNotEmpty) {
      try {
        // Poll for an NFC tag
        NFCTag tag = await FlutterNfcKit.poll();

        if (tag.ndefWritable == true) {
          String hexString = "2AAAA";

          NDEFRecord ndefRecord = TextRecord(text: hexString);

          await FlutterNfcKit.writeNDEFRecords([
            WellKnownRecord(
                decodedType: hexString, payload: hexToBytes(hexString))
          ]);

          setState(() {
            _writeResult = hexString;
          });
        } else {
          setState(() {
            _writeResult = 'Error: NDEF not supported';
          });
        }
      } catch (e) {
        setState(() {
          _writeResult = 'Error: $e';
        });
      } finally {
        await FlutterNfcKit.finish(iosAlertMessage: "Success");
      }
    } else {
      setState(() {
        _writeResult = 'Error: No record to write';
      });
    }
  }

  Future<void> startCycling() async {
    if (_records.isNotEmpty) {
      try {
        NFCTag tag = await FlutterNfcKit.poll();

        if (tag.ndefWritable == true) {
          String hexString = "2AAAA";

          NDEFRecord ndefRecord = TextRecord(text: hexString);

          await FlutterNfcKit.writeNDEFRecords([
            WellKnownRecord(
                decodedType: hexString, payload: hexToBytes(hexString))
          ]);

          setState(() {
            _writeResult = hexString;
          });
        } else {
          setState(() {
            _writeResult = 'Error: NDEF not supported';
          });
        }
      } catch (e) {
        setState(() {
          _writeResult = 'Error: $e';
        });
      } finally {
        await FlutterNfcKit.finish(iosAlertMessage: "Success");
      }
    } else {
      setState(() {
        _writeResult = 'Error: No record to write';
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NfcBloc(NfcService()),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('NFC Flutter Kit Example App'),
            bottom: TabBar(
              tabs: const <Widget>[
                Tab(text: 'Read'),
                Tab(text: 'Write'),
                Tab(text: 'Cycle')
              ],
              controller: _tabController,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              // Read NFC Tab
              Center(
                child: BlocBuilder<NfcBloc, NfcState>(
                  builder: (context, state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Button for starting NFC scanning
                        ElevatedButton(
                          onPressed: () {
                            context.read<NfcBloc>().add(ReadNfcTagEvent());
                          },
                          child: const Text("Start Scanning"),
                        ),
                        const SizedBox(height: 20),
                        // Display result or error
                        if (state is NfcScanningState)
                          const Text('Scanning for NFC tags...')
                        else if (state is NfcTagFoundState)
                          Text('Tag Found: ${state.tagId}')
                        else if (state is NfcTagReadState)
                          Text('Read Data: ${state.data}')
                        else if (state is NfcErrorState)
                          Text('Error: ${state.errorMessage}'),
                      ],
                    );
                  },
                ),
              ),
              // Write NFC Tab
              Center(
                child: BlocBuilder<NfcBloc, NfcState>(
                  builder: (context, state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Button for starting NFC writing
                        ElevatedButton(
                          onPressed: () {
                            context.read<NfcBloc>().add(WriteNfcTagEvent());
                          },
                          child: const Text("Start Writing"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<NfcBloc>().add(FillNfcTagEvent());
                          },
                          child: const Text("Fill NFC"),
                        ),
                        const SizedBox(height: 20),
                        // Display result or error
                        if (state is NfcTagWriteState)
                          Text('Write Result: ${state.status}')
                        else if (state is NfcErrorState)
                          Text('Error: ${state.errorMessage}'),
                      ],
                    );
                  },
                ),
              ),
              // Cycle NFC Tab
              Center(
                child: BlocBuilder<NfcBloc, NfcState>(
                  builder: (context, state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Button for starting NFC cycling
                        ElevatedButton(
                          onPressed: () {
                            context.read<NfcBloc>().add(CycleNfcTagEvent());
                          },
                          child: const Text("Start Cycling"),
                        ),
                        const SizedBox(height: 20),
                        // Display result or error
                        if (state is NfcTagCycleState)
                          Text('Cycle Result: ${state.status}')
                        else if (state is NfcErrorState)
                          Text('Error: ${state.errorMessage}'),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart';
import 'package:reminds_flutter/src/utils/testNfcData.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NFC Flutter Kit Example App'),
          bottom: TabBar(
            tabs: <Widget>[Tab(text: 'Read'), Tab(text: 'Write')],
            controller: _tabController,
          ),
        ),
        body: TabBarView(controller: _tabController, children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Platform: $_platformVersion\nNFC: $_availability'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: startPolling,
                  child: Text('Start polling'),
                ),
                const SizedBox(height: 10),
                _result.isNotEmpty
                    ? Text('Result:$_result')
                    : Text('No tag detected yet.'),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: startWriting,
                  child: Text("Start writing"),
                ),
                const SizedBox(height: 10),
                Text('Write Result: $_writeResult'),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: startCycling,
                  child: Text("Start Cycling"),
                ),
                const SizedBox(height: 10),
                Text('Write Result: $_writeResult'),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

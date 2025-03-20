import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:reminds_flutter/src/interfaces/mqtt_service_interface.dart';
import 'package:reminds_flutter/src/models/appConfig.dart';
import 'dart:io';
import 'package:typed_data/typed_data.dart' as typed;
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;

class MqttServiceMock implements MqttServiceInterface {
  final AppConfig config;
  MqttServerClient client;

  void Function(String topic)? _onSubscribedCallback;
  void Function(typed.Uint8Buffer buffer)? _onMessageRecieved;

  String get uploadTopic => '$config.project/$config.username/upload';
  String get downloadTopic => '$config.project/$config.username/download';

  typed.Uint8Buffer? _latestMessage;

  typed.Uint8Buffer? get latestMessage => _latestMessage;

  MqttServiceMock(this.config)
      : client = MqttServerClient(config.brokerDomain, config.clientId);

  @override
  void setCallbacks(
      void Function() onDisconnected, void Function(String topic) onConnected) {
    _onSubscribedCallback = onConnected;
  }

  @override
  void setMessageRecievedCallback(
      void Function(typed.Uint8Buffer buffer) onMessageRecieved) {
    _onMessageRecieved = onMessageRecieved;
  }

  @override
  Future<void> connect() async {
    sleep(const Duration(seconds: 1));
    _onSubscribedCallback?.call("fakeTopic");
  }

  @override
  void onSubscribed(String topic) {}

  @override
  void onConnected() {}

  @override
  void onDisconnected() {}

  @override
  void publishData(typed.Uint8Buffer buffer) {}

  @override
  void listenForMessage(List<MqttReceivedMessage<MqttMessage?>>? c) async {
    String jsonData = await rootBundle.loadString('assets/data/jsonData.json');

    // Convert the JSON string to bytes (Uint8List)
    // Uint8List bytes = Uint8List.fromList(utf8.encode(jsonData));

    // Parse the string into a JSON object.
    var jsonObject = jsonDecode(jsonData);

    // Re-encode the JSON object to a minified JSON string.
    String minifiedJson = jsonEncode(jsonObject);

    // Optionally, convert the minified JSON back to Uint8List.
    Uint8List bytes = Uint8List.fromList(utf8.encode(minifiedJson));

    // Cast the Uint8List to Uint8Buffer
    typed.Uint8Buffer data = typed.Uint8Buffer()..addAll(bytes);

    _latestMessage = data;
    _onMessageRecieved?.call(data);
  }

  @override
  void publishId(int id) {
    print("Publishing id $id");
    sleep(const Duration(seconds: 1));
    listenForMessage(null);
  }
}

import 'dart:convert';
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:reminds_flutter/src/interfaces/mqtt_service_interface.dart';
import 'package:reminds_flutter/src/models/appConfig.dart';
import 'dart:io';
import 'package:typed_data/typed_data.dart' as typed;
import 'package:flutter/services.dart';

const jsonData = "./jsonData.json";

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

  void setCallbacks(
      void Function() onDisconnected, void Function(String topic) onConnected) {
    _onSubscribedCallback = onConnected;
  }

  void setMessageRecievedCallback(
      void Function(typed.Uint8Buffer buffer) onMessageRecieved) {
    _onMessageRecieved = onMessageRecieved;
  }

  Future<void> connect() async {
    sleep(const Duration(seconds: 1));
    _onSubscribedCallback?.call("fakeTopic");
  }

  void onSubscribed(String topic) {}

  void onConnected() {}

  void onDisconnected() {}

  void publishId(String id) {
    print("Publishing id $id");
    sleep(const Duration(seconds: 1));
    listenForMessage(null);
  }

  void publishData(typed.Uint8Buffer buffer) {}

  void listenForMessage(List<MqttReceivedMessage<MqttMessage?>>? c) async {
    // Read JSON string from the file
    String jsonString = await File(jsonData).readAsString();

    // Convert the JSON string to bytes (Uint8List)
    Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

    // Cast the Uint8List to Uint8Buffer
    typed.Uint8Buffer data = typed.Uint8Buffer()..addAll(bytes);

    _latestMessage = data;
    _onMessageRecieved?.call(data);
  }
}

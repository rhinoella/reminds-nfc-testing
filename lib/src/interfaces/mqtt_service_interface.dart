import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:reminds_flutter/src/interfaces/mqtt_service_interface.dart';
import 'package:reminds_flutter/src/models/appConfig.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:typed_data/typed_data.dart' as typed;
import 'package:flutter/services.dart';

abstract class MqttServiceInterface {
  final AppConfig config;
  MqttServerClient client;

  void Function()? _onDisconnectedCallback;
  void Function(String topic)? _onSubscribedCallback;
  void Function(typed.Uint8Buffer buffer)? _onMessageRecieved;

  String get uploadTopic => '$config.project/$config.username/upload';
  String get downloadTopic => '$config.project/$config.username/download';

  typed.Uint8Buffer? _latestMessage;

  typed.Uint8Buffer? get latestMessage => _latestMessage;

  MqttServiceInterface(this.config)
      : client = MqttServerClient('sapphirewearables.com', "noella-test");

  void setCallbacks(
      void Function() onDisconnected, void Function(String topic) onConnected);

  void setMessageRecievedCallback(
      void Function(typed.Uint8Buffer buffer) onMessageRecieved);

  Future<void> connect();

  void onConnected();

  void onSubscribed(String topic);

  void onDisconnected();

  void publishId(String id);

  void publishData(typed.Uint8Buffer buffer);

  void listenForMessage(List<MqttReceivedMessage<MqttMessage?>>? c);
}

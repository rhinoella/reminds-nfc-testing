import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:reminds_flutter/src/interfaces/mqtt_service_interface.dart';
import 'package:reminds_flutter/src/models/appConfig.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:typed_data/typed_data.dart' as typed;
import 'package:flutter/services.dart';

class MqttService implements MqttServiceInterface {
  final AppConfig config;
  MqttServerClient client;

  void Function()? _onDisconnectedCallback;
  void Function(String topic)? _onSubscribedCallback;
  void Function(typed.Uint8Buffer buffer)? _onMessageRecieved;

  String get uploadTopic => '${config.project}/${config.username}/upload';
  String get downloadTopic => '${config.project}/${config.username}/download';

  typed.Uint8Buffer? _latestMessage;

  typed.Uint8Buffer? get latestMessage => _latestMessage;

  MqttService(this.config)
      : client = MqttServerClient(config.brokerDomain, config.clientId);

  void setCallbacks(
      void Function() onDisconnected, void Function(String topic) onConnected) {
    _onDisconnectedCallback = onDisconnected;
    _onSubscribedCallback = onConnected;
  }

  void setMessageRecievedCallback(
      void Function(typed.Uint8Buffer buffer) onMessageRecieved) {
    _onMessageRecieved = onMessageRecieved;
  }

  Future<void> connect() async {
    client.setProtocolV311();
    client.secure = true;
    client.port = config.brokerPort;

    // Create a new security context
    final SecurityContext context = SecurityContext.defaultContext;

    try {
      // Handle client certificate and key
      if (config.sslCertificate.isNotEmpty && config.sslKey.isNotEmpty) {
        // Convert certificate and key from PEM strings to bytes
        final certBytes = utf8.encode(config.sslCertificate);
        final keyBytes = utf8.encode(config.sslKey);

        // Use the certificate and key for client authentication
        context.useCertificateChainBytes(certBytes);
        context.usePrivateKeyBytes(keyBytes, password: config.p12Password);

        client.securityContext = context;
      }
    } catch (e) {
      print('Error setting up security context: $e');
    }

    client.keepAlivePeriod = 20;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;

    client.onSubscribed = onSubscribed;

    client.onBadCertificate = (Object a) {
      print('Bad certificate: $a');
      return true; // Accept bad certificates
    };

    final connMess = MqttConnectMessage()
        .authenticateAs(config.username, config.password)
        .withClientIdentifier(config.clientId)
        .startClean(); // Non persistent session for testing
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
      print('Connected to MQTT broker');
    } on Exception catch (e) {
      print('MQTT connection exception - $e');
      client.disconnect();
      return; // Don't exit the app, just return from the function
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      client.subscribe(downloadTopic, config.subscribeQos);
      client.subscribe(uploadTopic, config.subscribeQos);
      client.updates!.listen(listenForMessage);
    } else {
      print(
          'MQTT client connection failed - status: ${client.connectionStatus}');
      client.disconnect();
    }
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print("Subscribed to topic: $topic");
    _onSubscribedCallback?.call(topic);
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('MQTT client disconnected');
    _onDisconnectedCallback?.call();
  }

  /// The successful connect callback
  void onConnected() {
    print('OnConnected client callback - Client connection was successful');
  }

  void publishId(int id) {
    final builder = MqttClientPayloadBuilder();
    builder.addInt(id);
    client.publishMessage(uploadTopic, config.publishQos, builder.payload!);
  }

  void publishData(typed.Uint8Buffer buffer) {
    final builder = MqttClientPayloadBuilder();
    builder.addBuffer(buffer);
    client.publishMessage(uploadTopic, config.publishQos, builder.payload!);
  }

  void listenForMessage(List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final typed.Uint8Buffer payloadBytes = recMess.payload.message;

    _latestMessage = payloadBytes;
    _onMessageRecieved?.call(payloadBytes);
  }
}

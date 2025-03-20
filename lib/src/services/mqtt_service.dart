import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:reminds_flutter/src/interfaces/mqtt_service_interface.dart';
import 'package:reminds_flutter/src/models/appConfig.dart';
import 'dart:io';
import 'package:typed_data/typed_data.dart' as typed;
import 'package:flutter/services.dart';

class MqttService implements MqttServiceInterface {
  final AppConfig config;
  MqttServerClient client;

  void Function()? _onDisconnectedCallback;
  void Function(String topic)? _onSubscribedCallback;
  void Function(typed.Uint8Buffer buffer)? _onMessageRecieved;

  String get uploadTopic => '$config.project/$config.username/upload';
  String get downloadTopic => '$config.project/$config.username/download';

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

    final context = SecurityContext.defaultContext;
    final ByteData certificateData =
        await rootBundle.load('assets/cert/ca.crt');
    final ByteData keyData = await rootBundle.load('assets/cert/client.key');
    final ByteData clientCert = await rootBundle.load('assets/cert/client.crt');

    context.useCertificateChainBytes(clientCert.buffer.asUint8List());
    context.setTrustedCertificatesBytes(certificateData.buffer.asUint8List());
    context.usePrivateKeyBytes(keyData.buffer.asUint8List(),
        password: config.p12Password);

    client.keepAlivePeriod = 20;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;

    client.onSubscribed = onSubscribed;

    client.onBadCertificate = (Object a) => true;

    final connMess = MqttConnectMessage()
        .authenticateAs(config.username, config.password)
        .withClientIdentifier(config.clientId)
        .startClean(); // Non persistent session for testing
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      client.disconnect();
      exit(-1);
    }

    client.subscribe(downloadTopic, config.subscribeQos);
    client.subscribe(uploadTopic, config.subscribeQos);

    client.updates!.listen(listenForMessage);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print("Subscribed");
    _onSubscribedCallback?.call(topic);
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    _onDisconnectedCallback?.call();
  }

  /// The successful connect callback
  void onConnected() {
    print('OnConnected client callback - Client connection was sucessful');
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

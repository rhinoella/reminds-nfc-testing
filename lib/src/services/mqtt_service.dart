import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class MqttService {
  final String project = 'ReMINDS';
  final MqttQos subscribeQos = MqttQos.atLeastOnce;
  final MqttQos publishQos = MqttQos.atLeastOnce;
  final String brokerDomain = 'sapphirewearables.com';
  final int brokerPort = 8883;
  final String postCode = 'RG54ZW';
  final String countryCode = 'GB';
  final String username = 'NSpitz';
  final String password = '30011734';
  final String location = 'a Pharmacy';
  final String clientId = "noella-test";
  final String p12Password = "Laudy5^Ak%#eVXqNbqLW";
  MqttServerClient client;

  MqttService()
      : client = MqttServerClient('sapphirewearables.com', "noella-test");

  Future<void> connect() async {
    client.setProtocolV311();
    client.secure = true;
    client.port = brokerPort;

    final context = SecurityContext.defaultContext;
    final ByteData certificateData =
        await rootBundle.load('assets/cert/ca.crt');
    final ByteData keyData = await rootBundle.load('assets/cert/client.key');
    final ByteData clientCert = await rootBundle.load('assets/cert/client.crt');

    context.useCertificateChainBytes(clientCert.buffer.asUint8List());
    context.setTrustedCertificatesBytes(certificateData.buffer.asUint8List());
    context.usePrivateKeyBytes(keyData.buffer.asUint8List(),
        password: p12Password);

    client.keepAlivePeriod = 20;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;

    client.onSubscribed = onSubscribed;

    client.onBadCertificate = (Object a) => true;

    final connMess = MqttConnectMessage()
        .authenticateAs(username, password)
        .withClientIdentifier(clientId)
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

    final downloadTopic = '$project/$username/download';
    final uploadTopic = '$project/$username/upload';

    client.subscribe(downloadTopic, subscribeQos);
    client.subscribe(uploadTopic, subscribeQos);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}

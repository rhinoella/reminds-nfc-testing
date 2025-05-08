import 'package:mqtt_client/mqtt_client.dart';

class AppConfig {
  final mode = "prod";

  final String project;
  final MqttQos subscribeQos;
  final MqttQos publishQos;
  final String brokerDomain;
  final int brokerPort;
  final String postCode;
  final String countryCode;
  final String username;
  final String password;
  final String location;
  final String clientId;
  final String p12Password;
  final String sslCertificate;
  final String sslKey;

  // Constructor
  AppConfig({
    required this.project,
    required this.subscribeQos,
    required this.publishQos,
    required this.brokerDomain,
    required this.brokerPort,
    required this.postCode,
    required this.countryCode,
    required this.username,
    required this.password,
    required this.location,
    required this.clientId,
    required this.p12Password,
    required this.sslCertificate,
    required this.sslKey,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      project: json['project'] as String,
      subscribeQos: MqttQos.values[json['subscribeQos']],
      publishQos: MqttQos.values[json['publishQos']],
      brokerDomain: json['brokerDomain'] as String,
      brokerPort: json['brokerPort'] as int,
      postCode: json['postCode'] as String,
      countryCode: json['countryCode'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      location: json['location'] as String,
      clientId: json['clientId'] as String,
      p12Password: json['p12Password'] as String,
      sslCertificate: json['sslCertificate'] as String,
      sslKey: json['sslKey'] as String,
    );
  }

  AppConfig.dev()
      : project = "ReMINDS1",
        subscribeQos = MqttQos.atLeastOnce,
        publishQos = MqttQos.atLeastOnce,
        brokerDomain = "sapphirewearables.com",
        brokerPort = 8883,
        postCode = "RG54ZW",
        countryCode = "GB",
        username = "NSpitz",
        password = "30011734",
        location = "Test Location",
        clientId = "noella-test",
        p12Password = "Laudy5^Ak%#eVXqNbqLW",
        sslCertificate = "",
        sslKey = "";
}

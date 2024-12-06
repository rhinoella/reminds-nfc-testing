import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminds_flutter/src/services/mqtt_service.dart';
import 'package:reminds_flutter/src/widgets/connect.dart';
import 'package:reminds_flutter/src/widgets/loading.dart';
import 'package:reminds_flutter/src/widgets/nfc_scan.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider<MqttService>(create: (_) => MqttService()),
    ],
    child: MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NfcScan(), // Use LoadingScreen as the home screen
    );
  }
}

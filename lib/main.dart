import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminds_flutter/config.dart';
import 'package:reminds_flutter/src/interfaces/api_service_interface.dart';
import 'package:reminds_flutter/src/interfaces/mqtt_service_interface.dart';
import 'package:reminds_flutter/src/main/main_bloc.dart';
import 'package:reminds_flutter/src/main/main_page.dart';
import 'package:reminds_flutter/src/models/appConfig.dart';
import 'package:reminds_flutter/src/services/api_service.dart';
import 'package:reminds_flutter/src/services/mocks/api_service_mock.dart';
import 'package:reminds_flutter/src/services/mocks/mqtt_service_mock.dart';
import 'package:reminds_flutter/src/services/mqtt_service.dart';
import 'package:reminds_flutter/src/widgets/failure_screen.dart';
import 'package:reminds_flutter/src/widgets/loading.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late MqttServiceInterface mqttService;
  late ApiServiceInterface apiService;
  late AppConfig config;

  bool _isConnected = false;
  bool _connectionFailed = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    setState(() {
      _isConnected = false;
      _connectionFailed = false;
    });

    print("Initializing app in '$mode' mode, API URL: $apiUrl");

    apiService = mode == "dev"
        ? await ApiServiceMock.create(apiUrl)
        : await ApiService.create(apiUrl);

    try {
      config = await apiService.getConfig();
      await _connectToMqtt();
    } catch (e) {
      print("Error fetching config: $e");
      // Provide a fallback config if API call fails
      config = AppConfig.dev();

      try {
        await _connectToMqtt();
      } catch (mqttError) {
        print("Error connecting to MQTT: $mqttError");
        if (mounted) {
          setState(() {
            _isConnected = false;
            _connectionFailed = true;
          });
        }
      }
    }
  }

  Future<void> _connectToMqtt() async {
    mqttService = mode == "dev" ? MqttServiceMock(config) : MqttService(config);
    mqttService.setCallbacks(_handleDisconnect, _handleSubscribed);

    await mqttService.connect();
  }

  void _handleDisconnect() {
    print("Disconnected");
    if (mounted) {
      setState(() => _isConnected = false);
    }
    Future.delayed(
        const Duration(seconds: 3), _connectToMqtt); // Retry after 3 seconds
  }

  void _handleSubscribed(String topic) {
    if (mounted) {
      setState(() {
        _isConnected = true;
        _connectionFailed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnected) {
      return MultiProvider(providers: [
        Provider<RemindsBloc>(create: (_) => RemindsBloc()),
        Provider<MqttServiceInterface>(create: (_) => mqttService),
        Provider<ApiServiceInterface>(create: (_) => apiService),
      ], child: MaterialApp(home: RemindsMain()));
    } else if (_connectionFailed) {
      return MaterialApp(home: FailureScreen(onRetry: _initApp));
    } else {
      return MaterialApp(home: LoadingScreen());
    }
  }
}

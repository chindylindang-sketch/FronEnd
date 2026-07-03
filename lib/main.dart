import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/services/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/service_repository.dart';
import 'data/repositories/order_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set orientasi portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Ubah warna status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Setup Dependency Injection menggunakan Provider
  final apiClient = ApiClient();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthRepository>(
          create: (_) => AuthRepository(apiClient: apiClient),
        ),
        Provider<ServiceRepository>(
          create: (_) => ServiceRepository(apiClient: apiClient),
        ),
        Provider<OrderRepository>(
          create: (_) => OrderRepository(apiClient: apiClient),
        ),
      ],
      child: const App(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:laundrigo/app.dart';
import 'package:laundrigo/data/services/api_client.dart';
import 'package:laundrigo/data/repositories/auth_repository.dart';
import 'package:laundrigo/data/repositories/service_repository.dart';
import 'package:laundrigo/data/repositories/order_repository.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Setup Dependency Injection menggunakan Provider
    final apiClient = ApiClient();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
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

    // Advance time to clear Splash timer (which has Future.delayed of 2 seconds)
    await tester.pump(const Duration(seconds: 3));

    // Verify that the app navigates out of splash and renders something
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/service_repository.dart';
import 'data/repositories/order_repository.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/service/bloc/service_bloc.dart';
import 'presentation/order/bloc/order_bloc.dart';
import 'presentation/splash/pages/splash_page.dart';
import 'presentation/onboarding/pages/onboarding_page.dart';
import 'presentation/auth/pages/login_page.dart';
import 'presentation/auth/pages/register_page.dart';
import 'presentation/home/pages/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: context.read<AuthRepository>(),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<ServiceBloc>(
          create: (context) => ServiceBloc(
            serviceRepository: context.read<ServiceRepository>(),
          ),
        ),
        BlocProvider<OrderBloc>(
          create: (context) => OrderBloc(
            orderRepository: context.read<OrderRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'LaundriGo',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/onboarding': (context) => const OnboardingPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}

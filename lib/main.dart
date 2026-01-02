import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/pos_repository.dart';
import 'presentation/cubits/category_cubit.dart';
import 'presentation/cubits/order_cubit.dart';
import 'presentation/cubits/products_cubit.dart';
import 'presentation/cubits/sales_cubit.dart';
import 'presentation/cubits/orders_history_cubit.dart';
import 'presentation/views/home/home_screen.dart';

import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Top level repositories (Dependency Injection via Provider)
    return MultiProvider(
      providers: [
        Provider<PosRepository>(
          create: (_) => PosRepository(),
        ),
      ],
      child: const AppContent(),
    );
  }
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryCubit>(
          create: (context) => CategoryCubit(context.read<PosRepository>()),
        ),
        BlocProvider<ProductsCubit>(
          create: (context) => ProductsCubit(context.read<PosRepository>()),
        ),
        BlocProvider<OrderCubit>(
          create: (context) => OrderCubit(context.read<PosRepository>()),
        ),
        BlocProvider<SalesCubit>(
          create: (context) => SalesCubit(context.read<PosRepository>()),
        ),
        BlocProvider<OrdersHistoryCubit>(
          create: (context) => OrdersHistoryCubit(context.read<PosRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter POS',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}


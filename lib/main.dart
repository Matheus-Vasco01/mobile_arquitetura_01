import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'state/provider/counter_provider.dart';
import 'state/provider/product_provider.dart';
import 'state/provider/product_api_provider.dart';
import 'state/riverpod/product_riverpod_api.dart';
import 'state/bloc/product_bloc.dart';
import 'state/bloc/product_api_bloc.dart';
import 'data/datasources/product_remote_data_source.dart';
import 'data/datasources/product_local_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'core/session/session_manager.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final httpClient = http.Client();

  final productRepository = ProductRepositoryImpl(
    remoteDataSource: ProductRemoteDataSourceImpl(client: httpClient),
    localDataSource:
        ProductLocalDataSourceImpl(sharedPreferences: sharedPreferences),
  );

  runApp(
    ProviderScope(
      overrides: [
        productRepositoryProvider.overrideWithValue(productRepository),
      ],
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
            create: (_) => SessionManager(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => CounterProvider(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => ProductProvider(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => ProductApiProvider(repository: productRepository),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ProductBloc()),
            BlocProvider(
                create: (_) => ProductApiBloc(repository: productRepository)),
          ],
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loja de Produtos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B1123),
          primary: const Color(0xFF6B1123),
          surface: const Color(0xFFFDFBF9),
        ),
        scaffoldBackgroundColor: const Color(0xFFFDFBF9),
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B1123),
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B1123),
          ),
          headlineLarge: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B1123),
          ),
          headlineMedium: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B1123),
          ),
          titleLarge: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B1123),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFDFBF9),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: const Color(0xFF6B1123),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Color(0xFF6B1123)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B1123),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6B1123),
            side: const BorderSide(color: Color(0xFF6B1123)),
            textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: provider.Consumer<SessionManager>(
        builder: (context, session, _) {
          if (session.isLoggedIn) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}

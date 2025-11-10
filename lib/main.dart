// migue_admin/lib/main.dart (ACTUALIZADO CON ROUTER)

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migue_admin/config/router/app_router.dart'; // Importar el router
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_size/window_size.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Cargar las variables de entorno
  await dotenv.load(fileName: ".env");

  // 2. Configurar la ventana (solo para desktop)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Migue IPhones - Administrador');
    setWindowMinSize(const Size(1000, 700));
    setWindowMaxSize(Size.infinite);
  }

  // 3. Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    const ProviderScope(
      child: MainAdminApp(),
    ),
  );
}

class MainAdminApp extends ConsumerWidget { // 1. Cambiar a ConsumerWidget
  const MainAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // 2. Añadir WidgetRef ref
    
    // 3. Observar el proveedor del router
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: appRouter, // 4. Usar routerConfig
      debugShowCheckedModeBanner: false,
      title: 'Migue IPhones Admin',
      theme: _appTheme(),
      // home: const AdminScreen(), // 5. Eliminar el 'home'
    );
  }

  ThemeData _appTheme() {
    return ThemeData(
      brightness: Brightness.dark, 
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.dark,
        primary: const Color(0xFF007AFF),
      ),
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        titleLarge: TextStyle(fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
    );
  }
}
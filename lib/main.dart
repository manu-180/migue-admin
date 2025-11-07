// migue_admin/lib/main.dart (CON DOTENV)

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importar dotenv
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migue_admin/presentation/screens/admin/admin_screen.dart';
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
    setWindowMinSize(const Size(1000, 700)); // Mínimo para una buena vista de tabla
    setWindowMaxSize(Size.infinite);
  }

  // 3. Inicializar Supabase usando las variables de .env
  await Supabase.initialize(
    // Usamos dotenv.env[] para leer las variables
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    const ProviderScope(
      child: MainAdminApp(),
    ),
  );
}

class MainAdminApp extends StatelessWidget {
  const MainAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Migue IPhones Admin',
      theme: _appTheme(),
      // Pantalla principal de administración
      home: const AdminScreen(), 
    );
  }

  ThemeData _appTheme() {
    return ThemeData(
      // Tema Dark/Light para el escritorio (usaremos un tema oscuro para administración)
      brightness: Brightness.dark, 
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey, // Color más sobrio para admin
        brightness: Brightness.dark,
        primary: const Color(0xFF007AFF), // El mismo azul de Apple para consistencia
      ),
      scaffoldBackgroundColor: const Color(0xFF1E1E1E), // Fondo oscuro
      cardTheme: CardThemeData( // Usamos CardThemeData
        color: const Color(0xFF2D2D2D), // Cartas ligeramente más claras
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
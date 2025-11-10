// migue_admin/lib/config/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migue_admin/presentation/providers/auth/auth_provider.dart';
import 'package:migue_admin/presentation/screens/admin/admin_screen.dart';
import 'package:migue_admin/presentation/screens/login/login_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  // Observa el estado de autenticación
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/admin',
    routes: [
      GoRoute(
        path: '/login',
        name: LoginScreen.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: AdminScreen.name,
        builder: (context, state) => const AdminScreen(),
      ),
    ],
    
    // Lógica de Redirección
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = (authState != null);
      final isLoggingIn = (state.matchedLocation == '/login');

      if (!isLoggedIn && !isLoggingIn) {
        // Si no está logueado Y no está yendo a /login, redirigir a /login
        return '/login';
      }
      
      if (isLoggedIn && isLoggingIn) {
        // Si está logueado Y está intentando ir a /login, redirigir al admin
        return '/admin';
      }

      // En cualquier otro caso (logueado yendo a /admin, o no logueado yendo a /login), no hacer nada.
      return null;
    },
  );
}
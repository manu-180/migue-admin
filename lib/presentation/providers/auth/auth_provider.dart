// migue_admin/lib/presentation/providers/auth/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

// Este provider expone el cliente de Supabase
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}

// Este provider expone el estado de autenticación (logueado o no)
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  User? build() {
    // Escucha en tiempo real los cambios de autenticación
    final subscription =
        ref.read(supabaseClientProvider).auth.onAuthStateChange.listen((data) {
      state = data.session?.user;
    });

    // Limpia el listener cuando el provider es destruido
    ref.onDispose(() => subscription.cancel());

    // Devuelve el estado inicial (el usuario actual, si existe)
    return ref.read(supabaseClientProvider).auth.currentUser;
  }
}

// Este provider maneja la lógica de Login/Logout
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  // Método para iniciar sesión
  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
      return true;
    } on AuthException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      return false;
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return false;
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}
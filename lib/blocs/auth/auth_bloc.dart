import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {

    // 1. App Startup Check
    on<AppStarted>((event, emit) {
      final user = _auth.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });

    // 2. Login Logic
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(Authenticated(result.user!));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapAuthError(e.code)));
      } catch (e) {
        emit(AuthError("An unexpected error occurred."));
      }
    });

    // 3. SIGNUP LOGIC (Fixed)
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        // Firebase automatically logs the user in after signup
        emit(Authenticated(result.user!));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapAuthError(e.code)));
      } catch (e) {
        emit(AuthError("Could not create account. Please try again."));
      }
    });

    // 4. Sign Out Logic
    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      await _auth.signOut();
      emit(Unauthenticated());
    });
  }

  // Friendly Error Messages
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found': return "No account found for this email.";
      case 'wrong-password': return "Incorrect password.";
      case 'email-already-in-use': return "This email is already registered.";
      case 'weak-password': return "Password should be at least 6 characters.";
      case 'invalid-email': return "The email address is badly formatted.";
      default: return "Authentication failed ($code).";
    }
  }
}
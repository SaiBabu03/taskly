import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/Main_Screens/MainTasks_Screen.dart';
import 'package:taskly/Main_Screens/Signup_Screen.dart';
import 'package:taskly/blocs/auth/auth_bloc.dart';
import 'package:taskly/blocs/auth/auth_event.dart';
import 'package:taskly/blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value))
      return 'Please enter a valid email address';
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
    listener: (context, state) {
      // 1. Handle successful login navigation
      if (state is Authenticated) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainTasksScreen()),
              (route) => false, // Clears the login screen from history
        );
      }

      // 2. Handle errors (Your existing code)
      if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  _buildHeaderIcon(),
                  const SizedBox(height: 40),
                  const Text(
                    "Welcome back!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email Field
                  _buildInputField(
                    label: "EMAIL ADDRESS",
                    controller: _emailController,
                    hint: "email@example.com",
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  _buildInputField(
                    label: "PASSWORD",
                    controller: _passwordController,
                    hint: "********",
                    isPassword: true,
                    validator: (value) => value == null || value.length < 6
                        ? "Password must be at least 6 characters"
                        : null,
                  ),

                  const SizedBox(height: 30),

                  // Login Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7E7CF7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Log in",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "or log in with",
                    style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  _buildSocialRow(),
                  const SizedBox(height: 40),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    }
  }

  // --- UI HELPER METHODS ---

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD1D1D1),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? !_isPasswordVisible : false,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            hintText: hint,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF7E7CF7), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF7E7CF7),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E7CF7).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 55),
    );
  }

  Widget _buildSocialRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildSocialBtn(color: const Color(0xFF3B5998), icon: Icons.facebook),
      const SizedBox(width: 20),
      _buildSocialBtn(
        color: const Color(0xFFEA4335),
        icon: Icons.g_mobiledata,
        size: 40,
      ),
      const SizedBox(width: 20),
      _buildSocialBtn(color: Colors.black, icon: Icons.apple),
    ],
  );

  Widget _buildSocialBtn({
    required Color color,
    required IconData icon,
    double size = 24,
  }) => Container(
    width: 55,
    height: 55,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: Icon(icon, color: Colors.white, size: size),
  );

  Widget _buildFooter() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Don't have an account? ",
        style: TextStyle(color: Color(0xFF2D3142)),
      ),
      GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        ),
        child: const Text(
          "Get started!",
          style: TextStyle(
            color: Color(0xFF7E7CF7),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

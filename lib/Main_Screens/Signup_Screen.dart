  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:taskly/Main_Screens/Login_Screen.dart';
  import 'package:taskly/Main_Screens/MainTasks_Screen.dart';
  import 'package:taskly/blocs/auth/auth_bloc.dart';
  import 'package:taskly/blocs/auth/auth_event.dart';
  import 'package:taskly/blocs/auth/auth_state.dart';

  class SignupScreen extends StatefulWidget {
    const SignupScreen({super.key});

    @override
    State<SignupScreen> createState() => _SignupScreenState();
  }

  class _SignupScreenState extends State<SignupScreen> {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    bool _isPasswordVisible = false;

    String? _validateEmail(String? value) {
      if (value == null || value.isEmpty) return "Email is required";
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(value)) return "Enter a valid email address";
      return null;
    }

    String? _validatePassword(String? value) {
      if (value == null || value.isEmpty) return "Password is required";
      final passwordRegExp = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
      );
      if (!passwordRegExp.hasMatch(value)) {
        return "Use letters, numbers & symbols (Min. 8)";
      }
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
      final screenHeight = MediaQuery.of(context).size.height;

      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    _buildHeaderIcon(),
                    const SizedBox(height: 35),
                    const Text(
                      "Let's get started!",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 35),
                    _buildValidatedInput(
                      label: "EMAIL ADDRESS",
                      controller: _emailController,
                      validator: _validateEmail,
                      hint: "email@example.com",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildValidatedInput(
                      label: "PASSWORD",
                      controller: _passwordController,
                      validator: _validatePassword,
                      isPassword: true,
                      hint: "Letters, numbers & symbols",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- BLOC INTEGRATED SIGNUP BUTTON ---

                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is Authenticated) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainTasksScreen()),
                          );
                        }
                        if (state is AuthError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
                          );
                        }
                      },
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  SignUpRequested(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7E7CF7),
                              elevation: 4,
                              shadowColor: const Color(0xFF7E7CF7).withOpacity(0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Sign up",
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 25),
                    const Text("or sign up with", style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 20),
                    _buildSocialRow(),
                    const Spacer(),
                    _buildFooter(context),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // --- UI COMPONENTS (STYLES PRESERVED) ---

    Widget _buildValidatedInput({
      required String label,
      required TextEditingController controller,
      required String? Function(String?) validator,
      bool isPassword = false,
      String? hint,
      Widget? suffixIcon,
      TextInputType? keyboardType,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD1D1D1), letterSpacing: 0.8)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            obscureText: isPassword ? !_isPasswordVisible : false,
            keyboardType: keyboardType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFD1D1D1), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.transparent)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF7E7CF7), width: 2)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
        ],
      );
    }

    Widget _buildHeaderIcon() {
      return Center(
        child: SizedBox(
          width: 150, height: 120,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(top: 0, left: 10, child: _buildBall(10, const Color(0xFFFFA07A))),
              Positioned(bottom: 10, right: 0, child: _buildBall(12, const Color(0xFF7E7CF7).withOpacity(0.4))),
              Positioned(top: 20, right: 10, child: _buildBall(7, const Color(0xFF2D3142))),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF7E7CF7),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: const Color(0xFF7E7CF7).withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 55),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildBall(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

    Widget _buildSocialRow() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialBtn(color: const Color(0xFF3B5998), icon: Icons.facebook),
        const SizedBox(width: 20),
        _buildSocialBtn(color: const Color(0xFFEA4335), icon: Icons.g_mobiledata, size: 40),
        const SizedBox(width: 20),
        _buildSocialBtn(color: Colors.black, icon: Icons.apple),
      ],
    );

    Widget _buildSocialBtn({required Color color, required IconData icon, double size = 24}) => Container(
      width: 55, height: 55,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, color: Colors.white, size: size),
    );

    Widget _buildFooter(BuildContext context) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? ", style: TextStyle(fontSize: 15, color: Color(0xFF2D3142), fontWeight: FontWeight.w500)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          child: const Text("Log in", style: TextStyle(fontSize: 15, color: Color(0xFF7E7CF7), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
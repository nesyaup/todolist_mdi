import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'signin_screen.dart';
import 'todo_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    bool success = await AuthService().signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoScreen()),
      );
    } else {
      _showError('Email sudah terdaftar!');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.grey.shade900,
              Colors.grey.shade800,
              Colors.grey.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: isWide
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Ilustrasi bulat dengan efek glow
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purpleAccent.withOpacity(0.22),
                                  blurRadius: 60,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.10),
                              radius: 110,
                              child: Image.asset(
                                'assets/Icon-192.png.',
                                width: 160,
                                height: 160,
                              ),
                            ),
                          ),
                        ),
                        // Form di kanan
                        _buildSignUpForm(context, isWide: true),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ilustrasi bulat dengan efek glow
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.22),
                                blurRadius: 60,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.10),
                            radius: 90,
                            child: Image.asset(
                              'assets/Icon-192.png',
                              width: 120,
                              height: 120,
                            ),
                          ),
                        ),
                        // Form di bawah
                        _buildSignUpForm(context, isWide: false),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context, {required bool isWide}) {
    return Container(
      width: isWide ? 400 : null,
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      margin: EdgeInsets.symmetric(horizontal: isWide ? 0 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: 1.8,
        ),
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Sign Up",
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.2,
                shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            TextFormField(
              controller: _emailController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: GoogleFonts.poppins(color: Colors.white70),
                prefixIcon: Icon(Icons.email_rounded, color: Colors.purpleAccent.shade100),
                filled: true,
                fillColor: Colors.white.withOpacity(0.10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Masukkan email yang valid';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: GoogleFonts.poppins(color: Colors.white70),
                prefixIcon: Icon(Icons.lock_rounded, color: Colors.purpleAccent.shade100),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.purpleAccent.shade100,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _signUp();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.purpleAccent.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 10,
                  shadowColor: Colors.purpleAccent.shade200,
                  animationDuration: Duration(milliseconds: 300),
                ),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Sign Up',
                          key: ValueKey('signup'),
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
            ),
            SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('atau', style: GoogleFonts.poppins(color: Colors.white54, fontWeight: FontWeight.w500)),
                ),
                Expanded(child: Divider(color: Colors.white24, thickness: 1)),
              ],
            ),
            SizedBox(height: 18),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SignInScreen()),
              ),
              child: Text(
                'Sudah punya akun? Masuk',
                style: GoogleFonts.poppins(
                  color: Colors.purpleAccent.shade100,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  bool _resendCooldown = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final authProvider = context.read<AuthProvider>();
      await authProvider.reloadUser();
      if (!mounted) return;
      if (authProvider.isEmailVerified) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  Future<void> _resendVerification() async {
    setState(() => _resendCooldown = true);
    await context.read<AuthProvider>().firebaseUser?.sendEmailVerification();
    await Future.delayed(const Duration(seconds: 30));
    if (mounted) setState(() => _resendCooldown = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3460),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  color: Color(0xFF4ECDC4),
                  size: 50,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify your email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A verification link has been sent to\n${authProvider.firebaseUser?.email ?? ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8892B0),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please check your inbox and click the link to activate your account. This page will update automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8892B0),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Color(0xFF4ECDC4)),
              const SizedBox(height: 16),
              const Text(
                'Checking verification status...',
                style: TextStyle(color: Color(0xFF8892B0), fontSize: 14),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _resendCooldown ? null : _resendVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3460),
                    foregroundColor: const Color(0xFF4ECDC4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _resendCooldown ? 'Email sent (wait 30s)' : 'Resend verification email',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: Color(0xFF8892B0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
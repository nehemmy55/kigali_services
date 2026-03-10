import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as ap;

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late Timer _timer;
  int _refreshCountdown = 0;

  @override
  void initState() {
    super.initState();
    // Autocheck verification status every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        context.read<ap.AuthProvider>().checkEmailVerification();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _handleResendEmail() async {
    final authProvider = context.read<ap.AuthProvider>();
    await authProvider.resendVerificationEmail();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Disable resend button for 60 seconds
    setState(() => _refreshCountdown = 60);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_refreshCountdown <= 0) {
        timer.cancel();
        if (mounted) setState(() {});
      } else {
        if (mounted) setState(() => _refreshCountdown--);
      }
    });
  }

  Future<void> _handleSignOut() async {
    await context.read<ap.AuthProvider>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<ap.AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (authProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  authProvider.errorMessage!,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            const Icon(
              Icons.mark_email_read_outlined,
              size: 100,
              color: Color(0xFF005A9C),
            ),
            const SizedBox(height: 32),
            Text(
              'Verify your email address',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We have sent a verification link to:\n${authProvider.firebaseUser?.email}',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text(
              'Please check your inbox (and spam folder) and click the link to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => authProvider.checkEmailVerification(),
                child: const Text('I have verified my email'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _refreshCountdown > 0 ? null : _handleResendEmail,
              child: _refreshCountdown > 0
                  ? Text('Resend Email (${_refreshCountdown}s)')
                  : const Text('Resend verification email'),
            ),
          ],
        ),
      ),
    );
  }
}

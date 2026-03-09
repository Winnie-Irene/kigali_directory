import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _showErrorBanner(String message) {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFB71C1C),
        dividerColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).clearMaterialBanners(),
            child: const Text('Dismiss', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) ScaffoldMessenger.of(context).clearMaterialBanners();
    });
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
      _usernameController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/verify-email');
    } else {
      _showErrorBanner(authProvider.errorMessage ?? 'Signup failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1F2937)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Create account',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Join the Kigali Directory community',
                      style: TextStyle(color: Color(0xFF8892B0), fontSize: 16),
                    ),
                    const SizedBox(height: 36),
                    _buildField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'e.g. John Doe',
                      icon: Icons.person_outlined,
                      validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'e.g. john_kigali',
                      icon: Icons.alternate_email,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a username';
                        if (v.length < 3) return 'Username must be at least 3 characters';
                        if (v.contains(' ')) return 'Username cannot contain spaces';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Min 8 chars, letters, numbers & symbols',
                      icon: Icons.lock_outlined,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF8892B0)),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a password';
                        if (v.length < 8) return 'Password must be at least 8 characters';
                        if (!v.contains(RegExp(r'[A-Z]'))) return 'Include at least one uppercase letter';
                        if (!v.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
                        if (!v.contains(RegExp(r'[!@#\$&*~%^()_\-+=<>?]'))) return 'Include at least one special character (!@#\$&*~)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordStrengthIndicator(_passwordController.text),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      icon: Icons.lock_outlined,
                      obscure: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF8892B0)),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirm your password';
                        if (v != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildPrimaryButton(
                      label: 'Create Account',
                      isLoading: authProvider.isLoading,
                      onPressed: _handleSignup,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(color: Color(0xFF8892B0))),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text('Sign In', style: TextStyle(color: Color(0xFF4ECDC4), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFCDD6F4), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4A5568)),
            prefixIcon: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF111827),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1F2937))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1F2937))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE53935))),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE53935))),
            errorStyle: const TextStyle(color: Color(0xFFE53935)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#\$&*~%^()_\-+=<>?]'))) strength++;

    final labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      Colors.transparent,
      const Color(0xFFFF6B6B),
      const Color(0xFFFFE66D),
      const Color(0xFFFF8C42),
      const Color(0xFF6BCB77),
    ];

    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: i < strength ? colors[strength] : const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              strength > 0 ? 'Password strength: ${labels[strength]}' : '',
              style: TextStyle(color: colors[strength], fontSize: 12),
            ),
            const Spacer(),
            if (password.isNotEmpty)
              Text(
                '${password.length} chars',
                style: const TextStyle(color: Color(0xFF8892B0), fontSize: 11),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildRequirement('8+ characters', password.length >= 8),
            _buildRequirement('Uppercase', password.contains(RegExp(r'[A-Z]'))),
            _buildRequirement('Number', password.contains(RegExp(r'[0-9]'))),
            _buildRequirement('Symbol', password.contains(RegExp(r'[!@#\$&*~%^()_\-+=<>?]'))),
          ],
        ),
      ],
    );
  }

  Widget _buildRequirement(String label, bool met) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 12,
          color: met ? const Color(0xFF6BCB77) : const Color(0xFF4A5568),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: met ? const Color(0xFF6BCB77) : const Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({required String label, required bool isLoading, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF2EAF9F)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFF4ECDC4).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
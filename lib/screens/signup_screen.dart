import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/session_controller.dart';
import '../utils/form_validators.dart';
import 'field_selection_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthController authController = AuthController();
  final SessionController sessionController = SessionController();

  bool obscurePassword = true;
  bool isSubmitting = false;

  Future<void> registerUser() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      isSubmitting = true;
    });

    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    final isRegistered = await authController.registerUser(
      name,
      email,
      password,
    );

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    if (isRegistered) {
      await sessionController.saveLoginSession(email, rememberMe: true);
      await authController.claimLegacyData(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const FieldSelectionScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email already exists')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration({
    required String label,
    String? hint,
    String? helper,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      prefixIcon: icon == null ? null : Icon(icon),
      suffixIcon: suffixIcon,
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.library_books,
                        size: 46,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your subjects, notes, tasks, and mode choice stay attached to this email.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 26),
                      TextFormField(
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        decoration: fieldDecoration(
                          label: 'Full name',
                          hint: 'Your name',
                          helper: 'This appears on your local account.',
                          icon: Icons.person_outline,
                        ),
                        validator: (value) =>
                            FormValidators.requiredText(value, 'Full name'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: fieldDecoration(
                          label: 'Email',
                          hint: 'name@example.com',
                          helper: 'Use a valid email format.',
                          icon: Icons.mail_outline,
                        ),
                        validator: FormValidators.email,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: fieldDecoration(
                          label: 'Password',
                          helper: 'At least 6 characters.',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            tooltip: obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: FormValidators.password,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscurePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: fieldDecoration(
                          label: 'Confirm password',
                          icon: Icons.verified_user_outlined,
                        ),
                        validator: (value) => FormValidators.confirmPassword(
                          value,
                          passwordController.text,
                        ),
                        onFieldSubmitted: (_) => registerUser(),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: isSubmitting ? null : registerUser,
                          child: isSubmitting
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Create Account'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

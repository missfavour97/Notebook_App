import 'package:flutter/material.dart';
import 'field_selection_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/session_controller.dart';
import '../utils/form_validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthController authController = AuthController();
  final SessionController sessionController = SessionController();

  bool rememberMe = true;
  bool obscurePassword = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadRememberedLogin();
  }

  Future<void> loadRememberedLogin() async {
    final shouldRemember = await sessionController.shouldRememberUser();
    final rememberedEmail = await sessionController.getRememberedEmail();

    if (!mounted) return;

    setState(() {
      rememberMe = shouldRemember || rememberedEmail == null;
      emailController.text = rememberedEmail ?? '';
    });
  }

  Future<void> loginUser() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      isSubmitting = true;
    });

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    final isValidUser = await authController.loginUser(email, password);

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    if (isValidUser) {
      await sessionController.saveLoginSession(email, rememberMe: rememberMe);
      await authController.claimLegacyData(email);

      final savedField = await sessionController.getSavedField(email);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            if (savedField != null && savedField.isNotEmpty) {
              return HomeScreen(selectedField: savedField);
            }

            return const FieldSelectionScreen();
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  Future<void> showForgotPasswordDialog() async {
    final resetFormKey = GlobalKey<FormState>();
    final resetEmailController = TextEditingController(
      text: emailController.text.trim(),
    );
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final didReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        var obscureNewPassword = true;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Reset password'),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: resetFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: resetEmailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Account email',
                          helperText: 'Use the email you signed up with.',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormValidators.email,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNewPassword,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'New password',
                          helperText: 'At least 6 characters.',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: obscureNewPassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () {
                              setDialogState(() {
                                obscureNewPassword = !obscureNewPassword;
                              });
                            },
                            icon: Icon(
                              obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: FormValidators.password,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureNewPassword,
                        decoration: const InputDecoration(
                          labelText: 'Confirm new password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => FormValidators.confirmPassword(
                          value,
                          newPasswordController.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!(resetFormKey.currentState?.validate() ?? false)) {
                      return;
                    }

                    final wasReset = await authController.resetPassword(
                      resetEmailController.text.trim().toLowerCase(),
                      newPasswordController.text,
                    );

                    if (!dialogContext.mounted) return;

                    if (!wasReset) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('No account uses that email yet'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Reset'),
                ),
              ],
            );
          },
        );
      },
    );

    resetEmailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    if (!mounted || didReset != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated. You can log in now.')),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
            constraints: const BoxConstraints(maxWidth: 460),
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
                        Icons.auto_stories,
                        size: 46,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'My Notebook',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in with the email you used to create your account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 26),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'name@example.com',
                          prefixIcon: Icon(Icons.mail_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: FormValidators.email,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => loginUser(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
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
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value ?? true;
                                  });
                                },
                              ),
                              const Text('Remember me'),
                            ],
                          ),
                          TextButton(
                            onPressed: showForgotPasswordDialog,
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: isSubmitting ? null : loginUser,
                          child: isSubmitting
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text("Don't have an account? Sign up"),
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

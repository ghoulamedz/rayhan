import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rayhan_erp/providers/auth_provider.dart';
import 'package:rayhan_erp/screens/dashboard_screen.dart';
import 'package:rayhan_erp/widgets/custom/index.dart';

class LoginFormWidget extends StatefulWidget {
  final double? width;
  final double? height;

  const LoginFormWidget({
    super.key,
    this.width,
    this.height,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashboardScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
      // context.go('/dashboard');
    }
  }

  void onCancel() {
    Navigator.of(context).pop();
  }

  //  void _goToForgotPassword() {
  //   Navigator.of(context).push(
  //     PageRouteBuilder(
  //       pageBuilder: (_, __, ___) => const ForgotPasswordScreen(),
  //       transitionDuration: const Duration(milliseconds: 300),
  //       transitionsBuilder: (_, anim, __, child) =>
  //           FadeTransition(opacity: anim, child: child),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              iconSize: 20,
              icon: const Icon(Icons.close_rounded),
              onPressed: auth.isLoading ? null : onCancel,
              tooltip: 'Fermer',
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Connexion',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entrez vos identifiants pour accéder au système',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 28),
                  // Username field
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nom d\'utilisateur',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Champ obligatoire'
                        : null,
                    enabled: !auth.isLoading,
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!auth.isLoading) _submit();
                    },
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
                    enabled: !auth.isLoading,
                  ),
                  const SizedBox(height: 12),
                  // Error message
                  if (auth.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red[700], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Submit button
                  SizedBox(
                    height: 50,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : AppButton(
                            prefixIcon: Icons.login,
                            fontSize: 18,
                            variant: AppButtonVariant.primary,
                            padding: EdgeInsets.all(12),
                            label: 'Se connecter',
                            onTap: auth.isLoading ? null : _submit,
                          ),
                  ),

                  // Cancel button (optional, useful for dialogs)
                  const SizedBox(
                    height: 8,
                  ),

                  AppButton(
                    padding: EdgeInsets.all(12),
                    label: 'Mot de passe oublié ?',
                    variant: AppButtonVariant.secondary,
                    onTap: auth.isLoading ? null : onCancel,
                    prefixIcon: Icons.password,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

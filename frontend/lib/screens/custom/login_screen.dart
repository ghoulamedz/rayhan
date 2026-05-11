import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/widgets/custom/brand_panel.dart';
import 'package:rayhan_erp/widgets/custom/demo_hint.dart';
import 'package:rayhan_erp/widgets/custom/dialogs.dart';
import 'package:rayhan_erp/widgets/custom/error_banner.dart';
import 'package:rayhan_erp/widgets/custom/rayhan_logo.dart';
import 'package:rayhan_erp/widgets/custom/password_field.dart';
import 'main_layout.dart';

/// Login / authentication screen shown before [MainLayout].
///
/// On successful "login" it navigates to [MainLayout].
/// Connect to a real auth service in production.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'jean.dupont@plastiquerp.fr');
  final _password = TextEditingController(text: 'demo1234');

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final Animation<double> _fadeIn =
      CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  late final Animation<Offset> _slideIn = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    // Simulate network round-trip
    await Future.delayed(const Duration(milliseconds: 900));

    // Demo: always succeed for the email pre-filled
    if (_email.text.trim() == 'jean.dupont@plastiquerp.fr' &&
        _password.text == 'demo1234') {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainLayout(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    } else {
      setState(() {
        _loading = false;
        _error = 'Email ou mot de passe incorrect.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteSurface,
      body: Row(
        children: [
          // ── Left brand panel ──────────────────────────────────────────
          const BrandPanel(),

          // ── Right form panel ──────────────────────────────────────────
          Expanded(
            child: Center(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideIn,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.sp32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo (mobile / narrow — hidden on wide)
                          const RayhanLogo(),
                          const SizedBox(height: AppTheme.sp32),

                          // Heading
                          const Text(
                            'Connexion',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: AppTheme.sp4),
                          const Text(
                            'Accédez à votre espace PlastiqueERP.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.grey,
                            ),
                          ),
                          const SizedBox(height: AppTheme.sp32),

                          // Error banner
                          if (_error != null) ...[
                            ErrorBanner(message: _error!),
                            const SizedBox(height: AppTheme.sp16),
                          ],

                          // Form
                          Form(
                            key: _form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ErpTextField(
                                  label: 'Adresse email',
                                  required: true,
                                  controller: _email,
                                  hint: 'votre@email.com',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Champ requis';
                                    }
                                    if (!v.contains('@')) {
                                      return 'Email invalide';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppTheme.sp16),
                                PasswordField(
                                  controller: _password,
                                  obscure: _obscure,
                                  onToggle: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                const SizedBox(height: AppTheme.sp8),

                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                    ),
                                    child: const Text(
                                      'Mot de passe oublié ?',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppTheme.sp20),

                                // Submit
                                SizedBox(
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      disabledBackgroundColor:
                                          Colors.black.withValues(alpha: 0.6),
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Se connecter',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTheme.sp32),

                          // Demo hint
                          const DemoHint(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

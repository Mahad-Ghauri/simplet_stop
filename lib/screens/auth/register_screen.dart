// ignore_for_file: unused_field, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/authentication/auth_provider.dart';
import 'package:simplet_stop/services/localization_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final localizationService = Provider.of<LocalizationService>(
      context,
      listen: false,
    );

    final success = await authProvider.registerWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );

    if (success && mounted) {
      Helpers.showSnackBar(
        context,
        localizationService.tr('messages.success.registration'),
      );

      // New users should start with reading content
      AppRoutes.pushAndRemoveUntil(context, AppRoutes.readingContent);
    } else if (mounted && authProvider.error != null) {
      Helpers.showSnackBar(context, authProvider.error!, isError: true);
    }
  }

  void _navigateToLogin() {
    AppRoutes.pushReplacement(context, AppRoutes.login);
  }

  void _showLanguageSelector(
    BuildContext context,
    LocalizationService localizationService,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              localizationService.tr('profile.language'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...localizationService.getSupportedLanguages().entries.map(
              (entry) => ListTile(
                leading: Text(
                  _getLanguageFlag(entry.key),
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(entry.value),
                trailing: entry.key == localizationService.currentLanguage
                    ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                    : null,
                onTap: () async {
                  await localizationService.changeLanguage(entry.key);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LocalizationService>(
      builder: (context, authProvider, localizationService, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F5E8), // Light green at top
                  Color(0xFFF0F8F0), // Lighter green at bottom
                ],
              ),
            ),
            child: SafeArea(
              child: LoadingOverlay(
                isLoading: authProvider.isLoading,
                loadingMessage: localizationService.tr('auth.creating_account'),
                child: Stack(
                  children: [
                    // Language toggle button in top right
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          _showLanguageSelector(context, localizationService);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _getLanguageFlag(
                              localizationService.currentLanguage,
                            ),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),

                    // Main content with proper scrollable layout
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 
                                    MediaQuery.of(context).padding.top - 
                                    MediaQuery.of(context).padding.bottom - 80,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Main content container
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Logo using new PNG
                                      SizedBox(
                                        height: 80,
                                        child: Image.asset(
                                          'assets/images/simpelt_stop_logo_new.png',
                                          height: 80,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.app_registration,
                                              size: 80,
                                              color: Color(0xFF4CAF50),
                                            );
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Welcome text
                                      Text(
                                        localizationService.tr('auth.join_journey'),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Start your journey to quit nicotine today',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(height: 40),

                                      // Name field
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizationService.tr('auth.name') ?? 'Name',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[200]!,
                                              ),
                                            ),
                                            child: TextFormField(
                                              controller: _nameController,
                                              validator: Validators.validateName,
                                              decoration: InputDecoration(
                                                hintText: 'Dit navn',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[400],
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.person_outline,
                                                  color: Colors.grey[400],
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      // Email field
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizationService.tr('auth.email'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[200]!,
                                              ),
                                            ),
                                            child: TextFormField(
                                              controller: _emailController,
                                              validator: Validators.validateEmail,
                                              keyboardType: TextInputType.emailAddress,
                                              decoration: InputDecoration(
                                                hintText: 'din@email.dk',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[400],
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.email_outlined,
                                                  color: Colors.grey[400],
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      // Password field
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizationService.tr('auth.password'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[200]!,
                                              ),
                                            ),
                                            child: TextFormField(
                                              controller: _passwordController,
                                              validator: Validators.validatePassword,
                                              obscureText: _obscurePassword,
                                              decoration: InputDecoration(
                                                hintText: '••••••••',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[400],
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.lock_outline,
                                                  color: Colors.grey[400],
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscurePassword
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color: Colors.grey[400],
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscurePassword = !_obscurePassword;
                                                    });
                                                  },
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      // Confirm Password field
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizationService.tr('auth.confirm_password'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[200]!,
                                              ),
                                            ),
                                            child: TextFormField(
                                              controller: _confirmPasswordController,
                                              validator: (value) => Validators.validateConfirmPassword(
                                                value,
                                                _passwordController.text,
                                              ),
                                              obscureText: _obscureConfirmPassword,
                                              decoration: InputDecoration(
                                                hintText: '••••••••',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[400],
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.lock_outline,
                                                  color: Colors.grey[400],
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscureConfirmPassword
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color: Colors.grey[400],
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                                    });
                                                  },
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 32),

                                      // Register button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: authProvider.isLoading ? null : _register,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF4CAF50),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: authProvider.isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Text(
                                                  localizationService.tr('auth.create_account'),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // Login link
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '${localizationService.tr('auth.already_have_account')} ',
                                            ),
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: _navigateToLogin,
                                                child: Text(
                                                  localizationService.tr('auth.sign_in'),
                                                  style: const TextStyle(
                                                    color: Color(0xFF4CAF50),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Flexible spacer instead of Spacer() to prevent overflow
                              Flexible(
                                child: Container(
                                  height: 40, // Minimum space before footer
                                ),
                              ),

                              // Copyright footer
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  localizationService.tr('footer.copyright'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'da':
        return '🇩🇰';
      default:
        return '🌐';
    }
  }
}
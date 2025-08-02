// ignore_for_file: unused_field, prefer_final_fields, deprecated_member_use

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

  // Updated language selector to match login screen exactly
  void _showLanguageSelector(
    BuildContext context,
    LocalizationService localizationService,
  ) {
    print('Language selector tapped!'); // Debug print

    showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          enableDrag: true,
          isDismissible: true,
          builder: (BuildContext bottomSheetContext) {
            print('Building language selector modal'); // Debug print

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      localizationService.tr('profile.language'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Language options
                    ...localizationService.getSupportedLanguages().entries.map((
                      entry,
                    ) {
                      final isSelected =
                          entry.key == localizationService.currentLanguage;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              print(
                                'Language selected: ${entry.key}',
                              ); // Debug print

                              try {
                                await localizationService.changeLanguage(
                                  entry.key,
                                );
                                print(
                                  'Language changed successfully',
                                ); // Debug print

                                if (bottomSheetContext.mounted) {
                                  Navigator.pop(bottomSheetContext);
                                }
                              } catch (e) {
                                print(
                                  'Error changing language: $e',
                                ); // Debug print
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFF4CAF50),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _getLanguageFlag(entry.key),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? const Color(0xFF4CAF50)
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF4CAF50),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        )
        .then((value) {
          print('Language selector modal closed'); // Debug print
        })
        .catchError((error) {
          print('Error showing language selector: $error'); // Debug print
        });
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
                  Colors.white, // Changed to match login screen
                  Color(0xFFA3E4D7), // Light green at top - matching login
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Main content with proper spacing for language button
                  Positioned.fill(
                    child: LoadingOverlay(
                      isLoading: authProvider.isLoading,
                      loadingMessage: localizationService.tr('auth.creating_account'),
                      child: SingleChildScrollView(
                        // Updated padding to match login screen
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                MediaQuery.of(context).padding.bottom -
                                100,
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
                                        // Logo with error handling - matching login screen
                                        SizedBox(
                                          height: 80,
                                          child: Image.asset(
                                            'assets/images/logo.png', // Changed to match login screen
                                            height: 80,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.app_registration,
                                                size: 80,
                                                color: Color(0xFF1ABC9C), // Changed to match login screen
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
                                              localizationService.tr('auth.name'),
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

                                        // Register button - updated color to match login
                                        SizedBox(
                                          width: double.infinity,
                                          height: 52,
                                          child: ElevatedButton(
                                            onPressed: authProvider.isLoading ? null : _register,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFF48C9B0), // Changed to match login screen
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

                                        // Login link - updated color to match login
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
                                                      color: Color(0xFF48C9B0), // Changed to match login screen
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

                                // Flexible spacer
                                Flexible(child: Container(height: 40)),

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
                    ),
                  ),
                  
                  // Language toggle button (positioned on top with higher z-index) - matching login screen
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showLanguageSelector(context, localizationService);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getLanguageFlag(
                                  localizationService.currentLanguage,
                                ),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
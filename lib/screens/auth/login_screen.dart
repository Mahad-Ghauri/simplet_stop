// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/authentication/auth_provider.dart';
import 'package:simplet_stop/providers/progress/progress_provider.dart';
import 'package:simplet_stop/services/localization_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final localizationService = Provider.of<LocalizationService>(
      context,
      listen: false,
    );

    final success = await authProvider.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Helpers.showSnackBar(
        context,
        localizationService.tr('messages.success.login'),
      );

      // Check if user has completed reading content
      final progressProvider = Provider.of<ProgressProvider>(
        context,
        listen: false,
      );
      await progressProvider.loadProgress(authProvider.currentUser!.id);

      if (progressProvider.pagesRead < 9) {
        // Redirect to reading content if not completed
        AppRoutes.pushAndRemoveUntil(context, AppRoutes.readingContent);
      } else {
        // Redirect to dashboard if reading is completed
        AppRoutes.pushAndRemoveUntil(context, AppRoutes.dashboard);
      }
    } else if (mounted && authProvider.error != null) {
      Helpers.showSnackBar(context, authProvider.error!, isError: true);
    }
  }

  void _navigateToRegister() {
    AppRoutes.push(context, AppRoutes.register);
  }

  void _navigateToForgotPassword() {
    AppRoutes.push(context, AppRoutes.forgotPassword);
  }

  // FIXED: Improved language selector with better error handling and debugging
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

  // Fixed version - key changes in the build method

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
                  Colors.white, // Fixed: Changed to white for better contrast
                  Color(0xFFA3E4D7), // Light green at top
                  // Lighter green at bottom
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
                      loadingMessage: localizationService.tr('auth.signing_in'),
                      child: SingleChildScrollView(
                        // FIXED: Added top padding to account for language button
                        padding: const EdgeInsets.fromLTRB(
                          24,
                          80,
                          24,
                          20,
                        ), // Increased top padding from 60 to 80
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                MediaQuery.of(context).padding.bottom -
                                100, // Adjusted to account for new padding
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Logo with error handling
                                        SizedBox(
                                          height: 80,
                                          child: Image.asset(
                                            'assets/images/logo.png',
                                            height: 80,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.app_registration,
                                                    size: 80,
                                                    color: Color(0xFF1ABC9C),
                                                  );
                                                },
                                          ),
                                        ),

                                        const SizedBox(height: 32),

                                        // Welcome text
                                        Text(
                                          localizationService.tr(
                                            'auth.welcome',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          localizationService.tr(
                                            'auth.journey_subtitle',
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),

                                        const SizedBox(height: 40),

                                        // Email field
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              localizationService.tr(
                                                'auth.email',
                                              ),
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
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey[200]!,
                                                ),
                                              ),
                                              child: TextFormField(
                                                controller: _emailController,
                                                validator:
                                                    Validators.validateEmail,
                                                keyboardType:
                                                    TextInputType.emailAddress,
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
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  localizationService.tr(
                                                    'auth.password',
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey[200]!,
                                                ),
                                              ),
                                              child: TextFormField(
                                                controller: _passwordController,
                                                validator:
                                                    Validators.validatePassword,
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
                                                        _obscurePassword =
                                                            !_obscurePassword;
                                                      });
                                                    },
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 16,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 20),

                                        // Remember me checkbox
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _rememberMe = !_rememberMe;
                                                });
                                              },

                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: _rememberMe
                                                      ? Color(0xFF48C9B0)
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color: _rememberMe
                                                        ? const Color(
                                                            0xFF48C9B0,
                                                          )
                                                        : Colors.grey[400]!,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: _rememberMe
                                                    ? const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 14,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _rememberMe = !_rememberMe;
                                                });
                                              },
                                              child: Text(
                                                localizationService.tr(
                                                  'auth.remember_me',
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 120),
                                            TextButton(
                                              onPressed:
                                                  _navigateToForgotPassword,
                                              child: Text(
                                                localizationService.tr(
                                                  'auth.forgot_code',
                                                ),
                                                style: const TextStyle(
                                                  color: Color(0xFF48C9B0),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 32),

                                        // Login button
                                        SizedBox(
                                          width: double.infinity,
                                          height: 52,
                                          child: ElevatedButton(
                                            onPressed: authProvider.isLoading
                                                ? null
                                                : _login,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF48C9B0,
                                              ),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: authProvider.isLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : Text(
                                                    localizationService.tr(
                                                      'auth.sign_in',
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        // Register link
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${localizationService.tr('auth.dont_have_account')} ',
                                              ),
                                              WidgetSpan(
                                                child: GestureDetector(
                                                  onTap: _navigateToRegister,
                                                  child: Text(
                                                    localizationService.tr(
                                                      'auth.create_account_link',
                                                    ),
                                                    style: const TextStyle(
                                                      color: Color(0xFF48C9B0),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Forgot password link
                                        GestureDetector(
                                          onTap: _navigateToForgotPassword,
                                          child: Text(
                                            localizationService.tr(
                                              'auth.forgot_code',
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFF48C9B0),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
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

                  // Language toggle button (positioned on top with higher z-index)
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

import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/user_service.dart';
import '../utils/responsive_utils.dart';

class AuthScreen extends StatefulWidget {
  final bool isSignIn;

  const AuthScreen({super.key, required this.isSignIn});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isSignIn;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSignIn = widget.isSignIn;

    // Add listener to password field for real-time validation feedback
    _passwordController.addListener(() {
      if (!_isSignIn) {
        setState(() {
          // This will trigger a rebuild to update password requirements
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F4F0),
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: isSmallScreen ? 50 : 56,
        title: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: isSmallScreen ? 20 : 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            const Spacer(),
            Text(
              'Klinate',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20),
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 4),
                  ),

                  // Title with animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _isSignIn ? 'HELLO SIGN IN' : 'CREATE YOUR\nACCOUNT',
                      key: ValueKey(_isSignIn),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          22,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 12),
                  ),

                  // Form Container
                  Align(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveUtils.isSmallScreen(context)
                            ? double.infinity
                            : 380,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            14,
                          ),
                          vertical: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            12,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!_isSignIn) ...[
                                _buildTextField(
                                  controller: _firstNameController,
                                  hintText: 'First Name',
                                  icon: Icons.person_outline,
                                ),
                                SizedBox(
                                  height: ResponsiveUtils.getResponsiveSpacing(
                                    context,
                                    12,
                                  ),
                                ),
                                _buildTextField(
                                  controller: _lastNameController,
                                  hintText: 'Last Name',
                                  icon: Icons.person_outline,
                                ),
                                SizedBox(
                                  height: ResponsiveUtils.getResponsiveSpacing(
                                    context,
                                    12,
                                  ),
                                ),
                              ],
                              _buildTextField(
                                controller: _emailController,
                                hintText: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              if (!_isSignIn) ...[
                                SizedBox(
                                  height: ResponsiveUtils.getResponsiveSpacing(
                                    context,
                                    12,
                                  ),
                                ),
                                _buildTextField(
                                  controller: _phoneController,
                                  hintText: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  customValidator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Phone number is required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              SizedBox(
                                height: ResponsiveUtils.getResponsiveSpacing(
                                  context,
                                  12,
                                ),
                              ),
                              _buildTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                    size: ResponsiveUtils.isSmallScreen(context)
                                        ? 20
                                        : 24,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                customValidator: _isSignIn
                                    ? null
                                    : _validatePassword,
                              ),
                              if (!_isSignIn) ...[
                                SizedBox(
                                  height: ResponsiveUtils.getResponsiveSpacing(
                                    context,
                                    8,
                                  ),
                                ),
                                _buildPasswordRequirements(),
                              ],
                              if (!_isSignIn) ...[
                                SizedBox(
                                  height: ResponsiveUtils.getResponsiveSpacing(
                                    context,
                                    16,
                                  ),
                                ),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  hintText: 'Confirm Password',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscureConfirmPassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                      size:
                                          ResponsiveUtils.isSmallScreen(context)
                                          ? 20
                                          : 24,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  customValidator: _validateConfirmPassword,
                                ),
                              ],
                              if (_isSignIn) ...[
                                SizedBox(
                                  height: ResponsiveUtils.getResponsiveSpacing(
                                    context,
                                    12,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Handle forgot password
                                    },
                                    child: Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            ResponsiveUtils.getResponsiveFontSize(
                                              context,
                                              14,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              SizedBox(
                                height: ResponsiveUtils.getResponsiveSpacing(
                                  context,
                                  12,
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.symmetric(
                                      vertical:
                                          ResponsiveUtils.getResponsiveSpacing(
                                            context,
                                            12,
                                          ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: const BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height:
                                              ResponsiveUtils.isSmallScreen(
                                                context,
                                              )
                                              ? 18
                                              : 20,
                                          width:
                                              ResponsiveUtils.isSmallScreen(
                                                context,
                                              )
                                              ? 18
                                              : 20,
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.black,
                                                strokeWidth: 2,
                                              ),
                                        )
                                      : Text(
                                          _isSignIn ? 'SIGN IN' : 'SIGN UP',
                                          style: TextStyle(
                                            fontSize:
                                                ResponsiveUtils.getResponsiveFontSize(
                                                  context,
                                                  16,
                                                ),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveUtils.getResponsiveSpacing(
                                  context,
                                  10,
                                ),
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    _isSignIn
                                        ? "Don't have an account? "
                                        : "Have an account? ",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                          ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            14,
                                          ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isSignIn = !_isSignIn;
                                        _clearForm();
                                      });
                                    },
                                    child: Text(
                                      _isSignIn ? 'SIGN UP' : 'SIGN IN',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            ResponsiveUtils.getResponsiveFontSize(
                                              context,
                                              14,
                                            ),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? customValidator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey,
          size: ResponsiveUtils.isSmallScreen(context) ? 20 : 24,
        ),
        suffixIcon: suffixIcon,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
        ),
        isDense: ResponsiveUtils.isSmallScreen(context),
      ),
      validator:
          customValidator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $hintText';
            }
            return null;
          },
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;

    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 10),
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password must contain:',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
          _buildRequirementItem('At least 6 characters', password.length >= 6),
          _buildRequirementItem(
            'At least one uppercase letter',
            RegExp(r'[A-Z]').hasMatch(password),
          ),
          _buildRequirementItem(
            'At least one number',
            RegExp(r'[0-9]').hasMatch(password),
          ),
          _buildRequirementItem(
            'At least one special character',
            RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 2),
      ),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: ResponsiveUtils.isSmallScreen(context) ? 14 : 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 6)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
                color: isMet ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignIn) {
        // Sign In
        final result = await UserService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (result.success) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          if (mounted) {
            _showErrorDialog(result.message);
          }
        }
      } else {
        // Sign Up
        final result = await UserService.signUp(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

        if (result.success) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          if (mounted) {
            _showErrorDialog(result.message);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('An error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: const TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

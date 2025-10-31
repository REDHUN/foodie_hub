import 'package:flutter/material.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/providers/auth_provider.dart';
import 'package:foodiehub/screens/owner_dashboard_screen.dart';
import 'package:foodiehub/services/restaurant_service.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:provider/provider.dart';

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Restaurant details for registration
  final TextEditingController _restaurantNameController = TextEditingController();
  final TextEditingController _cuisineController = TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController(text: '30-40 mins');
  final TextEditingController _deliveryFeeController = TextEditingController(text: '0');
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _restaurantNameController.dispose();
    _cuisineController.dispose();
    _deliveryTimeController.dispose();
    _deliveryFeeController.dispose();
    _imageUrlController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLoginMode) {
        await authProvider.signIn(email, password);
      } else {
        await _registerOwner(authProvider, email, password);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      final message = authProvider.errorMessage ?? e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _registerOwner(AuthProvider authProvider, String email, String password) async {
    final user = await authProvider.signUp(email, password);
    if (user == null) {
      throw Exception('Failed to create account. Please try again.');
    }

    final restaurantName = _restaurantNameController.text.trim();
    final cuisine = _cuisineController.text.trim();
    final deliveryTime = _deliveryTimeController.text.trim();
    final imageUrl = _imageUrlController.text.trim().isEmpty
        ? 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe'
        : _imageUrlController.text.trim();
    final discount = _discountController.text.trim().isEmpty
        ? null
        : _discountController.text.trim();

    double deliveryFee = 0.0;
    try {
      deliveryFee = double.parse(_deliveryFeeController.text.trim());
    } catch (_) {
      deliveryFee = 0.0;
    }

    final restaurantId = 'rest_${DateTime.now().millisecondsSinceEpoch}';
    final restaurant = Restaurant(
      id: restaurantId,
      name: restaurantName,
      image: imageUrl,
      cuisine: cuisine,
      rating: 0,
      deliveryTime: deliveryTime,
      deliveryFee: deliveryFee,
      discount: discount,
      ownerId: user.uid,
    );

    final success = await RestaurantService().addRestaurant(restaurant);
    if (!success) {
      await authProvider.signOut();
      throw Exception('Failed to create restaurant. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Restaurant Owner Login' : 'Restaurant Owner Sign Up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLoginMode
                      ? 'Log in to manage your restaurant menu and orders.'
                      : 'Create an account and set up your restaurant in a few steps.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                if (!_isLoginMode) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm your password';
                      }
                      if (value != _passwordController.text.trim()) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Restaurant Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _restaurantNameController,
                    label: 'Restaurant Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Restaurant name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cuisineController,
                    label: 'Cuisine (e.g. Italian, Fast Food)',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cuisine is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _deliveryTimeController,
                    label: 'Delivery Time (e.g. 30-40 mins)',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _deliveryFeeController,
                    label: 'Delivery Fee (₹)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _imageUrlController,
                    label: 'Restaurant Image URL (optional)',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _discountController,
                    label: 'Discount Info (optional)',
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(authProvider.isLoading
                      ? 'Please wait...'
                      : (_isLoginMode ? 'Login' : 'Create Account')),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: authProvider.isLoading ? null : _toggleMode,
                  child: Text(_isLoginMode
                      ? "Don't have an account? Sign up"
                      : 'Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}


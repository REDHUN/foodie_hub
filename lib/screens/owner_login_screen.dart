import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/providers/auth_provider.dart';
import 'package:foodiehub/screens/owner_dashboard_screen.dart';
import 'package:foodiehub/services/restaurant_service.dart';
import 'package:foodiehub/widgets/animated_header.dart';
import 'package:foodiehub/widgets/beautiful_button.dart';
import 'package:foodiehub/widgets/beautiful_text_field.dart';
import 'package:foodiehub/widgets/restaurant_owner_illustration.dart';
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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Restaurant details for registration
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _cuisineController = TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController(
    text: '30-40 mins',
  );
  final TextEditingController _deliveryFeeController = TextEditingController(
    text: '0',
  );
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
      final message =
          authProvider.errorMessage ??
          e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _registerOwner(
    AuthProvider authProvider,
    String email,
    String password,
  ) async {
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFF8F9FA),
        body: SingleChildScrollView(
          child: Column(
            children: [
              AnimatedHeader(
                title: _isLoginMode ? 'Welcome Back!' : 'Join FoodieHub',
                subtitle: _isLoginMode
                    ? 'Log in to manage your restaurant menu and orders'
                    : 'Create an account and set up your restaurant in a few steps',
                illustration: RestaurantOwnerIllustration(
                  size: 100,
                  isLoginMode: _isLoginMode,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BeautifulTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
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
                      const SizedBox(height: 20),
                      BeautifulTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey[600],
                          ),
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
                        const SizedBox(height: 20),
                        BeautifulTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
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
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFF6B6B,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.restaurant_menu,
                                      color: Color(0xFFFF6B6B),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Restaurant Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              BeautifulTextField(
                                controller: _restaurantNameController,
                                label: 'Restaurant Name',
                                hint: 'e.g. Mario\'s Pizza Palace',
                                prefixIcon: Icons.store_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Restaurant name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              BeautifulTextField(
                                controller: _cuisineController,
                                label: 'Cuisine Type',
                                hint: 'e.g. Italian, Fast Food, Asian',
                                prefixIcon: Icons.restaurant_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Cuisine is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              BeautifulTextField(
                                controller: _deliveryTimeController,
                                label: 'Delivery Time',
                                hint: 'e.g. 30-40 mins',
                                prefixIcon: Icons.access_time_outlined,
                              ),
                              const SizedBox(height: 16),
                              BeautifulTextField(
                                controller: _deliveryFeeController,
                                label: 'Delivery Fee (₹)',
                                hint: 'e.g. 50',
                                prefixIcon: Icons.delivery_dining_outlined,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              BeautifulTextField(
                                controller: _imageUrlController,
                                label: 'Restaurant Image URL',
                                hint: 'Optional - paste image URL here',
                                prefixIcon: Icons.image_outlined,
                              ),
                              const SizedBox(height: 16),
                              BeautifulTextField(
                                controller: _discountController,
                                label: 'Discount Offer',
                                hint: 'e.g. 50% OFF UPTO ₹100',
                                prefixIcon: Icons.local_offer_outlined,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      BeautifulButton(
                        text: _isLoginMode
                            ? 'Login to Dashboard'
                            : 'Create Restaurant Account',
                        icon: _isLoginMode
                            ? Icons.login
                            : Icons.restaurant_menu,
                        onPressed: authProvider.isLoading
                            ? null
                            : _handleSubmit,
                        isLoading: authProvider.isLoading,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : _toggleMode,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 16),
                              children: [
                                TextSpan(
                                  text: _isLoginMode
                                      ? "Don't have an account? "
                                      : 'Already have an account? ',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: _isLoginMode ? 'Sign up' : 'Login',
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

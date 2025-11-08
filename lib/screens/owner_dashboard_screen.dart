import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/models/menu_item.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/providers/auth_provider.dart';
import 'package:foodiehub/providers/location_provider.dart';
import 'package:foodiehub/providers/menu_cart_provider.dart';
import 'package:foodiehub/providers/menu_item_provider.dart';
import 'package:foodiehub/screens/owner_login_screen.dart';
import 'package:foodiehub/services/restaurant_service.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:foodiehub/widgets/reliable_image.dart';
import 'package:foodiehub/widgets/shimmer_loading.dart';
import 'package:provider/provider.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  bool _isLoading = true;
  String? _error;
  Restaurant? _restaurant;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOwnerData();
    });
  }

  Future<void> _loadOwnerData() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    final authProvider = context.read<AuthProvider>();
    final menuItemProvider = context.read<MenuItemProvider>();
    final user = authProvider.user;

    if (user == null) {
      setState(() {
        _error = 'You must be logged in to view this page.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final restaurant = await _restaurantService.getRestaurantByOwnerId(
        user.uid,
      );
      if (restaurant == null) {
        setState(() {
          _restaurant = null;
          _error = 'No restaurant found for this account.';
          _isLoading = false;
        });
        return;
      }

      await menuItemProvider.loadMenuItemsForRestaurant(restaurant.id);

      if (!mounted) return;
      setState(() {
        _restaurant = restaurant;
        _isLoading = false;
        _error = null;
      });

      // Update location provider with restaurant location
      final locationProvider = context.read<LocationProvider>();
      locationProvider.updateLocationFromRestaurant(restaurant.location);

      // Add success haptic feedback
      HapticFeedback.lightImpact();

      // // Show success message
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Dashboard refreshed! 📊'),
      //       duration: Duration(seconds: 2),
      //       backgroundColor: AppColors.successColor,
      //       behavior: SnackBarBehavior.floating,
      //     ),
      //   );
      // }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load restaurant data. Please try again.';
        _isLoading = false;
      });

      // Add error haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _handleSignOut() async {
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<MenuCartProvider>();
    try {
      await authProvider.signOut();
      // Clear cart when restaurant owner logs out
      cartProvider.clearCartOnLogout();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to sign out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItemProvider = context.watch<MenuItemProvider>();
    final menuItems = _restaurant != null
        ? menuItemProvider.getMenuItemsByRestaurant(_restaurant!.id)
        : <MenuItem>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Dashboard'),
        actions: [
          IconButton(
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      floatingActionButton: _restaurant == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primaryColor,
              onPressed: menuItemProvider.isLoading
                  ? null
                  : _showAddMenuItemDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Menu Item',
                style: TextStyle(color: Colors.white),
              ),
            ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadOwnerData,
          child: _buildBody(menuItemProvider, menuItems),
        ),
      ),
    );
  }

  Widget _buildBody(
    MenuItemProvider menuItemProvider,
    List<MenuItem> menuItems,
  ) {
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShimmerLoading(isLoading: true, child: const OwnerDashboardShimmer()),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadOwnerData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_restaurant == null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                const Icon(Icons.restaurant, size: 56, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No restaurant linked to this account.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your restaurant profile to start managing your menu and orders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OwnerLoginScreen(),
                      ),
                    );
                    // Refresh data if restaurant was created
                    if (result == true) {
                      _loadOwnerData();
                    }
                  },
                  icon: const Icon(Icons.add_business, color: Colors.white),
                  label: const Text(
                    'Create Restaurant',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Contact support at support@foodiehub.com for assistance',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    'Need help? Contact Support',
                    style: TextStyle(
                      color: Colors.grey[600],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRestaurantCard(_restaurant!),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Menu Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (menuItemProvider.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (menuItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: const Center(
              child: Text(
                'No menu items yet. Add your first dish!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          ...menuItems.map((item) => _buildMenuItemTile(item)),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ReliableRestaurantImage(
                imageUrl: restaurant.image,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => _showEditRestaurantDialog(restaurant),
                    icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                    tooltip: 'Edit Restaurant Details',
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant.cuisine,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (restaurant.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.location!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange[400], size: 20),
                    const SizedBox(width: 4),
                    Text(restaurant.rating.toStringAsFixed(1)),
                    const SizedBox(width: 16),
                    const Icon(Icons.timer, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(restaurant.deliveryTime),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.delivery_dining,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text('₹${restaurant.deliveryFee.toStringAsFixed(2)}'),
                  ],
                ),
                if (restaurant.discount != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      restaurant.discount!,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemTile(MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ReliableImage(
                  imageUrl: item.image,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  category: item.category,
                  borderRadius: BorderRadius.zero,
                ),
                // Category Badge
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Description
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price and Quantity Row
                    Row(
                      children: [
                        // Price Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.currency_rupee,
                                size: 14,
                                color: AppColors.primaryColor,
                              ),
                              Text(
                                item.price.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Quantity Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: item.quantity == 0
                                ? Colors.red.withValues(alpha: 0.1)
                                : item.isLowStock
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 14,
                                color: item.quantity == 0
                                    ? Colors.red[700]
                                    : item.isLowStock
                                    ? Colors.orange[700]
                                    : Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: item.quantity == 0
                                      ? Colors.red[700]
                                      : item.isLowStock
                                      ? Colors.orange[700]
                                      : Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Action Buttons
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: Colors.blue[700],
                            onPressed: () => _showEditMenuItemDialog(item),
                            tooltip: 'Edit',
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: Colors.red[700],
                            onPressed: () => _confirmDeleteMenuItem(item),
                            tooltip: 'Delete',
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddMenuItemDialog() async {
    if (_restaurant == null) return;

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final imageController = TextEditingController();
    final categoryController = TextEditingController();
    final quantityController = TextEditingController(text: '999');
    final formKey = GlobalKey<FormState>();
    final menuItemProvider = context.read<MenuItemProvider>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add Menu Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(
                    controller: nameController,
                    label: 'Name',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildDialogTextField(
                    controller: descriptionController,
                    label: 'Description',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _buildDialogTextField(
                    controller: priceController,
                    label: 'Price (₹)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDialogTextField(
                    controller: categoryController,
                    label: 'Category',
                  ),
                  const SizedBox(height: 12),
                  _buildDialogTextField(
                    controller: quantityController,
                    label: 'Quantity (Stock)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantity is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDialogTextField(
                    controller: imageController,
                    label: 'Image URL',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.red),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final price =
                    double.tryParse(priceController.text.trim()) ?? 0.0;
                final quantity =
                    int.tryParse(quantityController.text.trim()) ?? 999;
                final newMenuItem = MenuItem(
                  id: 'menu_${DateTime.now().millisecondsSinceEpoch}',
                  restaurantId: _restaurant!.id,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  price: price,
                  image: imageController.text.trim().isEmpty
                      ? 'https://picsum.photos/seed/food${DateTime.now().millisecondsSinceEpoch}/300/200'
                      : imageController.text.trim(),
                  category: categoryController.text.trim().isEmpty
                      ? 'General'
                      : categoryController.text.trim(),
                  quantity: quantity,
                );

                final success = await menuItemProvider.addMenuItem(
                  _restaurant!.id,
                  newMenuItem,
                );

                if (!mounted) return;
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menu item added successfully'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add menu item')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        labelText: label,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      validator: validator,
    );
  }

  Future<void> _showEditMenuItemDialog(MenuItem item) async {
    if (_restaurant == null) return;

    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price.toString());
    final imageController = TextEditingController(text: item.image);
    final categoryController = TextEditingController(text: item.category);
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final formKey = GlobalKey<FormState>();
    final menuItemProvider = context.read<MenuItemProvider>();
    bool isUpdating = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Edit Menu Item'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogTextField(
                        controller: nameController,
                        label: 'Name',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: descriptionController,
                        label: 'Description',
                        maxLines: 3,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Description is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: priceController,
                        label: 'Price (₹)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Price is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: categoryController,
                        label: 'Category',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Category is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: quantityController,
                        label: 'Quantity (Stock)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Quantity is required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: imageController,
                        label: 'Image URL',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Image URL is required'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: isUpdating
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setState(() {
                            isUpdating = true;
                          });

                          try {
                            final price =
                                double.tryParse(priceController.text.trim()) ??
                                0.0;
                            final quantity =
                                int.tryParse(quantityController.text.trim()) ??
                                999;

                            final updatedMenuItem = MenuItem(
                              id: item.id,
                              restaurantId: item.restaurantId,
                              name: nameController.text.trim(),
                              description: descriptionController.text.trim(),
                              price: price,
                              image: imageController.text.trim(),
                              category: categoryController.text.trim(),
                              quantity: quantity,
                            );

                            final success = await menuItemProvider
                                .updateMenuItem(
                                  _restaurant!.id,
                                  updatedMenuItem,
                                );

                            if (!mounted) return;

                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Menu item updated successfully! ✨',
                                  ),
                                  backgroundColor: AppColors.successColor,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update menu item'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                isUpdating = false;
                              });
                            }
                          }
                        },
                  child: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditRestaurantDialog(Restaurant restaurant) async {
    final nameController = TextEditingController(text: restaurant.name);
    final cuisineController = TextEditingController(text: restaurant.cuisine);
    final deliveryTimeController = TextEditingController(
      text: restaurant.deliveryTime,
    );
    final deliveryFeeController = TextEditingController(
      text: restaurant.deliveryFee.toString(),
    );
    final imageController = TextEditingController(text: restaurant.image);
    final discountController = TextEditingController(
      text: restaurant.discount ?? '',
    );
    final locationController = TextEditingController(
      text: restaurant.location ?? '',
    );
    final formKey = GlobalKey<FormState>();
    bool isUpdating = false;
    bool isGettingLocation = false;
    GeoPoint? geopoint = restaurant.geopoint; // Store GPS data directly

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Edit Restaurant Details'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogTextField(
                        controller: nameController,
                        label: 'Restaurant Name',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Restaurant name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: cuisineController,
                        label: 'Cuisine Type',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Cuisine type is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: deliveryTimeController,
                        label: 'Delivery Time (e.g., 30-45 min)',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Delivery time is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: deliveryFeeController,
                        label: 'Delivery Fee (₹)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Delivery fee is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: imageController,
                        label: 'Restaurant Image URL',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Image URL is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: discountController,
                        label: 'Discount Offer (Optional)',
                      ),
                      const SizedBox(height: 12),
                      // Location field with GPS button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDialogTextField(
                              controller: locationController,
                              label: 'Restaurant Location',
                              readOnly: true,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Location is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            child: ElevatedButton(
                              onPressed: isGettingLocation || isUpdating
                                  ? null
                                  : () async {
                                      setState(() {
                                        isGettingLocation = true;
                                      });

                                      try {
                                        final locationProvider = context
                                            .read<LocationProvider>();
                                        final position = await locationProvider
                                            .getUserLocation();

                                        if (position != null) {
                                          setState(() {
                                            geopoint = GeoPoint(
                                              position.latitude,
                                              position.longitude,
                                            );

                                            if (locationProvider
                                                .locationName
                                                .isNotEmpty) {
                                              locationController.text =
                                                  locationProvider.locationName;
                                            }
                                          });

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Location obtained! 📍',
                                                ),
                                                backgroundColor:
                                                    AppColors.successColor,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } finally {
                                        setState(() {
                                          isGettingLocation = false;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isGettingLocation
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      geopoint != null
                                          ? Icons.check_circle
                                          : Icons.my_location,
                                      size: 18,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      // GPS status message
                      if (geopoint != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'GPS location set',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: isUpdating
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setState(() {
                            isUpdating = true;
                          });

                          try {
                            final deliveryFee =
                                double.tryParse(
                                  deliveryFeeController.text.trim(),
                                ) ??
                                0.0;

                            final updatedRestaurant = Restaurant(
                              id: restaurant.id,
                              name: nameController.text.trim(),
                              cuisine: cuisineController.text.trim(),
                              rating: restaurant.rating, // Keep existing rating
                              deliveryTime: deliveryTimeController.text.trim(),
                              deliveryFee: deliveryFee,
                              image: imageController.text.trim(),
                              discount: discountController.text.trim().isEmpty
                                  ? null
                                  : discountController.text.trim(),
                              ownerId: restaurant.ownerId,
                              location: locationController.text.trim().isEmpty
                                  ? null
                                  : locationController.text.trim(),
                              geopoint: geopoint, // Include GPS coordinates
                            );

                            final success = await _restaurantService
                                .updateRestaurant(updatedRestaurant);

                            if (!mounted) return;

                            if (success) {
                              Navigator.pop(context);
                              // Refresh the restaurant data
                              await _loadOwnerData();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Restaurant details updated successfully! ✨',
                                  ),
                                  backgroundColor: AppColors.successColor,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to update restaurant details',
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                isUpdating = false;
                              });
                            }
                          }
                        },
                  child: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteMenuItem(MenuItem item) async {
    if (_restaurant == null) return;
    final menuItemProvider = context.read<MenuItemProvider>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Menu Item'),
          content: Text('Are you sure you want to delete "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await menuItemProvider.deleteMenuItem(
      _restaurant!.id,
      item.id,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menu item deleted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete menu item')),
      );
    }
  }
}

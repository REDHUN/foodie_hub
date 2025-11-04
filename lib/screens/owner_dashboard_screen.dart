import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/models/menu_item.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/providers/auth_provider.dart';
import 'package:foodiehub/providers/location_provider.dart';
import 'package:foodiehub/providers/menu_cart_provider.dart';
import 'package:foodiehub/providers/menu_item_provider.dart';
import 'package:foodiehub/screens/restaurant_setup_screen.dart';
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
      HapticFeedback.selectionClick();

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
      HapticFeedback.heavyImpact();
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
                        builder: (context) => const RestaurantSetupScreen(),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: ReliableImage(
          imageUrl: item.image,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          category: item.category,
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text('₹${item.price.toStringAsFixed(2)} • ${item.category}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primaryColor,
              ),
              onPressed: () => _showEditMenuItemDialog(item),
              tooltip: 'Edit Menu Item',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteMenuItem(item),
              tooltip: 'Delete Menu Item',
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
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final price =
                    double.tryParse(priceController.text.trim()) ?? 0.0;
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,

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

                            final updatedMenuItem = MenuItem(
                              id: item.id,
                              restaurantId: item.restaurantId,
                              name: nameController.text.trim(),
                              description: descriptionController.text.trim(),
                              price: price,
                              image: imageController.text.trim(),
                              category: categoryController.text.trim(),
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
                      _buildDialogTextField(
                        controller: locationController,
                        label: 'Location (e.g., Downtown, City Center)',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Location is required'
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

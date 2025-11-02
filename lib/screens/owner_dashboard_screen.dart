import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/models/menu_item.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/providers/auth_provider.dart';
import 'package:foodiehub/providers/menu_item_provider.dart';
import 'package:foodiehub/services/restaurant_service.dart';
import 'package:foodiehub/utils/constants.dart';
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

      // Add success haptic feedback
      HapticFeedback.selectionClick();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dashboard refreshed! 📊'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
    try {
      await authProvider.signOut();
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
              children: const [
                Icon(Icons.restaurant, size: 56, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No restaurant linked to this account.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Please contact support to link your restaurant.',
                  textAlign: TextAlign.center,
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
          ...menuItems.map((item) => _buildMenuItemTile(item)).toList(),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: restaurant.image,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.white,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 160,
                color: Colors.white,
                child: const Icon(
                  Icons.restaurant,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant.cuisine,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
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
                      color: AppColors.primaryColor.withOpacity(0.1),
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
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: item.image,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 56,
              height: 56,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 56,
              height: 56,
              color: Colors.grey[200],
              child: const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
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
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDeleteMenuItem(item),
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
                      ? 'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f'
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
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
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

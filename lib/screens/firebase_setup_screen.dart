import 'package:flutter/material.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:foodiehub/utils/firebase_migration.dart';
import 'package:foodiehub/services/restaurant_service.dart';
import 'package:foodiehub/services/menu_item_service.dart';
import 'package:foodiehub/providers/restaurant_provider.dart';
import 'package:foodiehub/providers/menu_item_provider.dart';
import 'package:provider/provider.dart';

class FirebaseSetupScreen extends StatefulWidget {
  const FirebaseSetupScreen({super.key});

  @override
  State<FirebaseSetupScreen> createState() => _FirebaseSetupScreenState();
}

class _FirebaseSetupScreenState extends State<FirebaseSetupScreen> {
  final FirebaseMigration _migration = FirebaseMigration();
  final RestaurantService _restaurantService = RestaurantService();
  final MenuItemService _menuItemService = MenuItemService();
  
  bool _isLoading = false;
  String _status = 'Ready to migrate';
  int _restaurantCount = 0;
  int _menuItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final restaurants = await _restaurantService.getRestaurants();
    final menuItems = await _menuItemService.getMenuItems();
    setState(() {
      _restaurantCount = restaurants.length;
      _menuItemCount = menuItems.length;
    });
  }

  Future<void> _migrateData() async {
    setState(() {
      _isLoading = true;
      _status = 'Migrating data to Firebase...';
    });

    try {
      await _migration.migrateSampleData();
      setState(() {
        _status = 'Migration successful!';
      });
      await _loadCounts();
      
      // Show success dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data migrated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Trigger providers to reload
      if (mounted) {
        await Provider.of<RestaurantProvider>(context, listen: false).loadRestaurants();
        await Provider.of<MenuItemProvider>(context, listen: false).loadMenuItems();
      }
    } catch (e) {
      setState(() {
        _status = 'Migration failed: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Migration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to clear ALL data from Firebase? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _status = 'Clearing data...';
      });

      try {
        await _migration.clearAllData();
        setState(() {
          _status = 'Data cleared';
        });
        await _loadCounts();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data cleared'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _status = 'Failed to clear data: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Setup'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _status,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Restaurants',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_restaurantCount',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Menu Items',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_menuItemCount',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _migrateData,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_isLoading ? 'Migrating...' : 'Migrate Sample Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _clearData,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear All Data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Click "Migrate Sample Data" to populate Firebase with sample restaurants and menu items.\n\n'
                '2. Once migrated, your data will be stored in Firestore.\n\n'
                '3. Use "Clear All Data" to start fresh (use with caution!).\n\n'
                '4. The app will automatically use Firebase data once available.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


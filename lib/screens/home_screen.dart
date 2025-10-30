import 'package:flutter/material.dart';
import 'package:foodiehub/models/product.dart';
import 'package:foodiehub/providers/cart_provider.dart';
import 'package:foodiehub/providers/product_provider.dart';
import 'package:foodiehub/screens/add_product_screen.dart';
import 'package:foodiehub/screens/product_detail_screen.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:foodiehub/widgets/cart_item_widget.dart';
import 'package:foodiehub/widgets/product_card.dart';
import 'package:foodiehub/widgets/search_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _filteredProducts = [];
  String _selectedCategory = Categories.all;
  SortOption _sortOption = SortOption.featured;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      setState(() {
        _filteredProducts = productProvider.products;
      });
    });
  }

  void _filterProducts() {
    setState(() {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      List<Product> filtered = List.from(productProvider.products);

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((product) {
          return product.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              product.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              product.category.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
        }).toList();
      }

      // Filter by category
      if (_selectedCategory != Categories.all) {
        filtered = filtered
            .where((product) => product.category == _selectedCategory)
            .toList();
      }

      // Sort products
      switch (_sortOption) {
        case SortOption.priceLow:
          filtered.sort((a, b) => a.price.compareTo(b.price));
          break;
        case SortOption.priceHigh:
          filtered.sort((a, b) => b.price.compareTo(a.price));
          break;
        case SortOption.rating:
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case SortOption.newest:
          filtered.sort((a, b) => b.id.compareTo(a.id));
          break;
        case SortOption.featured:
          break;
      }

      _filteredProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Update filtered products when provider changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_filteredProducts.length != productProvider.products.length) {
            _filterProducts();
          }
        });

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                // Navigation
                _buildNavigation(),
                // Hero Section
                _buildHeroSection(),
                // Filter Section
                _buildFilterSection(),
                // Products
                Expanded(child: _buildProductsGrid()),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductScreen(),
                ),
              ).then((_) {
                // Refresh products after adding
                _filterProducts();
              });
            },
            backgroundColor: AppColors.primaryColor,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Product',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          const Icon(
            Icons.restaurant_menu,
            color: AppColors.primaryColor,
            size: 28,
          ),
          const SizedBox(width: 8),
          const Text(
            'FoodieHub',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 28),
                onPressed: () => _openCart(),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    if (cart.itemCount > 0) {
                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: AppColors.secondaryColor,
            child: Text(
              'JD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    final categories = [
      Categories.all,
      Categories.pizza,
      Categories.burger,
      Categories.sushi,
      Categories.dessert,
      Categories.beverage,
    ];

    return Container(
      color: AppColors.darkColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SearchBarWidget(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _filterProducts();
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: categories.map((category) {
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(
                      category[0].toUpperCase() + category.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _filterProducts();
                    },
                    selectedColor: AppColors.primaryColor,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.8),
            AppColors.secondaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Delicious Food Delivered',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Order from the best restaurants in your area',
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<SortOption>(
              value: _sortOption,
              decoration: const InputDecoration(
                labelText: 'Sort by',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: SortOption.featured,
                  child: Text('Featured'),
                ),
                DropdownMenuItem(
                  value: SortOption.priceLow,
                  child: Text('Price: Low to High'),
                ),
                DropdownMenuItem(
                  value: SortOption.priceHigh,
                  child: Text('Price: High to Low'),
                ),
                DropdownMenuItem(
                  value: SortOption.rating,
                  child: Text('Highest Rated'),
                ),
                DropdownMenuItem(
                  value: SortOption.newest,
                  child: Text('Newest First'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortOption = value;
                  });
                  _filterProducts();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.6,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return ProductCard(
            product: product,
            onTap: () => _openProductDetail(product),
            onAddToCart: () => _addToCart(product),
          );
        },
      ),
    );
  }

  void _addToCart(Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart!'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.successColor,
      ),
    );
  }

  void _openProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartBottomSheet(),
    );
  }
}

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Cart',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Items
                  Expanded(
                    child: cart.items.isEmpty
                        ? const Center(
                            child: Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(15),
                            children: cart.items.map((item) {
                              return CartItemWidget(
                                item: item,
                                onIncrease: () {
                                  cart.updateQuantity(
                                    item.product.id,
                                    item.quantity + 1,
                                  );
                                },
                                onDecrease: () {
                                  cart.updateQuantity(
                                    item.product.id,
                                    item.quantity - 1,
                                  );
                                },
                                onRemove: () {
                                  cart.removeFromCart(item.product.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Item removed from cart'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                  ),
                  // Footer
                  if (cart.items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${cart.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                cart.clearCart();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Order placed successfully!',
                                    ),
                                    backgroundColor: AppColors.successColor,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

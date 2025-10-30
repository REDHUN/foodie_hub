import 'package:flutter/material.dart';
import 'package:foodiehub/models/product.dart';
import 'package:foodiehub/providers/product_provider.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewsController = TextEditingController();

  String _selectedCategory = Categories.pizza;
  String? _badge;

  final List<String> _badges = [
    'Bestseller',
    'Popular',
    'Chef\'s Special',
    'Must Try',
    'Vegetarian',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _ratingController.dispose();
    _reviewsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: Provider.of<ProductProvider>(context, listen: false).nextProductId,
        name: _nameController.text,
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        image: _imageUrlController.text.isEmpty
            ? 'https://picsum.photos/seed/${_nameController.text}/300/200.jpg'
            : _imageUrlController.text,
        rating: double.tryParse(_ratingController.text) ?? 4.0,
        reviews: int.tryParse(_reviewsController.text) ?? 0,
        badge: _badge,
      );

      Provider.of<ProductProvider>(context, listen: false).addProduct(product);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: AppColors.successColor,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fastfood),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    [
                      Categories.pizza,
                      Categories.burger,
                      Categories.sushi,
                      Categories.dessert,
                      Categories.beverage,
                    ].map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category[0].toUpperCase() + category.substring(1),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  helperText: 'Leave empty for random image',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Rating',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.star),
                        helperText: 'Default: 4.0',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final rating = double.tryParse(value);
                          if (rating == null || rating < 0 || rating > 5) {
                            return 'Rating must be 0-5';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _reviewsController,
                      decoration: const InputDecoration(
                        labelText: 'Reviews',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.reviews),
                        helperText: 'Default: 0',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final reviews = int.tryParse(value);
                          if (reviews == null || reviews < 0) {
                            return 'Invalid number';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _badge,
                decoration: const InputDecoration(
                  labelText: 'Badge (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('None'),
                  ),
                  ..._badges.map((badge) {
                    return DropdownMenuItem(value: badge, child: Text(badge));
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _badge = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Add Product',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

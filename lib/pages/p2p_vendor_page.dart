
import 'package:flutter/material.dart';

// Data class for a physical product
class Product {
  String name;
  String description;
  int points;

  Product({required this.name, required this.description, required this.points});
}

class P2PVendorPage extends StatefulWidget {
  const P2PVendorPage({super.key});

  @override
  State<P2PVendorPage> createState() => _P2PVendorPageState();
}

class _P2PVendorPageState extends State<P2PVendorPage> {
  final String _language = 'hi'; // or 'en'
  final List<Product> _products = [
    Product(name: 'Handmade Scarf', description: 'A beautiful handmade scarf.', points: 1500),
    Product(name: 'Spicy Mixture', description: 'A pack of delicious spicy mixture.', points: 300),
  ];

  void _addProduct() {
    // Show a dialog to add a new product
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final pointsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_language == 'hi' ? 'नया प्रोडक्ट जोड़ें' : 'Add New Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: _language == 'hi' ? 'प्रोडक्ट का नाम' : 'Product Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: _language == 'hi' ? 'विवरण' : 'Description'),
            ),
            TextField(
              controller: pointsController,
              decoration: InputDecoration(labelText: _language == 'hi' ? 'पॉइंट्स (कीमत)' : 'Points (Price)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_language == 'hi' ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text;
              final description = descriptionController.text;
              final points = int.tryParse(pointsController.text) ?? 0;

              if (name.isNotEmpty && description.isNotEmpty && points > 0) {
                setState(() {
                  _products.add(Product(name: name, description: description, points: points));
                });
                Navigator.pop(context);
              }
            },
            child: Text(_language == 'hi' ? 'जोड़ें' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_language == 'hi' ? 'आपकी P2P दुकान' : 'Your P2P Store'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.blueGrey),
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(product.description),
              trailing: Text(
                '${product.points} ${_language == 'hi' ? 'पॉइंट्स' : 'Points'}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        label: Text(_language == 'hi' ? 'नया प्रोडक्ट जोड़ें' : 'Add Product'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}

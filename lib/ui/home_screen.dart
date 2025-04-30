import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lks_mobile/ui/ereceipt_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  HomeScreen({required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List products = [];
  List<Map<String, dynamic>> selectedProducts = [];

  void getProducts() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/produk');
    final request = await HttpClient().getUrl(url);
    request.headers.set(HttpHeaders.acceptHeader, "application/json");
    request.headers.set(
        HttpHeaders.authorizationHeader, "Bearer ${widget.token}");

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      setState(() {
        products = data['data'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Widget buildProductCard(Map product) {
    final nama = product['nama'].toString().toLowerCase();
    final imagePathJpg = 'assets/image/$nama.jpg';
    final imagePathPng = 'assets/image/$nama.png';
    final isSelected = selectedProducts.contains(product);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      color: isSelected ? Colors.green[100] : null,
      child: ListTile(
        leading: Image.asset(
          imagePathJpg,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              imagePathPng,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, size: 50);
              },
            );
          },
        ),
        title: Text(product['nama']),
        subtitle: Text('Rp${product['harga']} • Stok: ${product['stok']}'),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.add_circle_outline,
          color: isSelected ? Colors.green : null,
        ),
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedProducts.remove(product);
            } else {
              selectedProducts.add(Map<String, dynamic>.from(product));
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Produk')),
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  buildProductCard(products[index]),
            ),
      floatingActionButton: selectedProducts.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EReceiptScreen(selectedProducts: selectedProducts),
                  ),
                );
              },
              icon: Icon(Icons.payment),
              label: Text("Bayar"),
            )
          : null,
    );
  }
}

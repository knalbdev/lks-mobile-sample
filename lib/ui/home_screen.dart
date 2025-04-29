import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  HomeScreen({required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List products = [];

  void getProducts() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/produk');
    final request = await HttpClient().getUrl(url);
    request.headers.set(HttpHeaders.acceptHeader, "application/json");
    request.headers.set(HttpHeaders.authorizationHeader, "Bearer ${widget.token}");

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
    final imagePathJpg = 'assets/images/$nama.jpg';
    final imagePathPng = 'assets/images/$nama.png';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
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
              itemBuilder: (context, index) => buildProductCard(products[index]),
            ),
    );
  }
}

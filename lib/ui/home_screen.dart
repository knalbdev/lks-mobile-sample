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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Produk')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return ListTile(
            title: Text(p['nama']),
            subtitle: Text('Rp${p['harga']} • Stok: ${p['stok']}'),
          );
        },
      ),
    );
  }
}

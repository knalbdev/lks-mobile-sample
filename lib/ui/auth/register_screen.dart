import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String nama = '';
  String username = '';
  String email = '';
  String alamat = '';
  String password = '';
  String errorMessage = '';
  bool isLoading = false;

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final url = Uri.parse('http://10.0.2.2:8000/api/register');
      final request = await HttpClient().postUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json");
      request.add(utf8.encode(jsonEncode({
        'nama_lengkap': nama,
        'name': username,
        'alamat': alamat,
        'email': email,
        'password': password,
      })));

      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        final body = await response.transform(utf8.decoder).join();
        setState(() {
          errorMessage = 'Registrasi gagal: $body';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal menghubungi server';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget inputField(String label, Function(String) onChanged, String? Function(String?) validator, {bool obscure = false}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      obscureText: obscure,
      onChanged: onChanged,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            inputField('Nama Lengkap', (val) => nama = val, (val) => val!.isEmpty ? 'Nama tidak boleh kosong' : null),
            inputField('Username', (val) => username = val, (val) => val!.isEmpty ? 'Username tidak boleh kosong' : null),
            inputField('Alamat', (val) => alamat = val, (val) => val!.isEmpty ? 'Alamat tidak boleh kosong' : null),
            inputField('Email', (val) => email = val, (val) => val!.isEmpty ? 'Email tidak boleh kosong' : null),
            inputField('Password', (val) => password = val, (val) => val!.isEmpty ? 'Password tidak boleh kosong' : null, obscure: true),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: register, child: Text('Register')),
            SizedBox(height: 10),
            Text(errorMessage, style: TextStyle(color: Colors.red)),
          ]),
        ),
      ),
    );
  }
}

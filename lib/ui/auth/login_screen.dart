import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lks_mobile/ui/auth/register_screen.dart';
import 'package:lks_mobile/ui/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String errorMessage = '';
  bool isLoading = false;

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final url = Uri.parse('http://10.0.2.2:8000/api/login');
      final request = await HttpClient().postUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json");
      request.add(utf8.encode(jsonEncode({
        'email': email,
        'password': password,
      })));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final token = data['data']['token'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(token: token)),
        );
      } else {
        setState(() {
          errorMessage = 'Email atau password salah';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (val) => email = val,
              validator: (value) => value!.isEmpty ? 'Email tidak boleh kosong' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (val) => password = val,
              validator: (value) => value!.isEmpty ? 'Password tidak boleh kosong' : null,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: Text('Login')),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              ),
              child: Text("Belum punya akun? Register"),
            ),
            SizedBox(height: 10),
            Text(errorMessage, style: TextStyle(color: Colors.red)),
          ]),
        ),
      ),
    );
  }
}

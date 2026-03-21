import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập (Auth)')),
      body: const Center(
        child: Text('DEV 1: Code giao diện Đăng Nhập ở đây...'),
      ),
    );
  }
}

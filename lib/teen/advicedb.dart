import 'package:flutter/material.dart';

class AdviceDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Professional Advice", style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "No content available.",
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
  
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart'; // SQLite DB helper
import 'addult/homecontent.dart'; // Adult user HomeContent
import 'teen/profilecontent.dart'; // Reusing ProfileContent
import 'teen/analyticscontent.dart'; // Reusing AnalyticsContent
import 'login.dart'; // Login screen

class AdultDashboard extends StatefulWidget {
  final String username;

  const AdultDashboard({Key? key, required this.username}) : super(key: key);

  @override
  _AdultDashboardState createState() => _AdultDashboardState();
}

class _AdultDashboardState extends State<AdultDashboard> {
  int _selectedIndex = 0;
  Map<String, dynamic> userData = {};

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadUserData() async {
    final user = await DatabaseHelper.instance.getUser(widget.username);
    if (user != null) {
      setState(() {
        userData = user;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not found')),
      );
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null || username.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      await _loadUserData();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (userData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _selectedIndex == 0
                ? HomeContent(username: widget.username)
                : _selectedIndex == 1
                    ? const AnalyticsContent()
                    : ProfileContent(username: widget.username),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analytics"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: _onItemTapped,
      ),
    );
  }
}

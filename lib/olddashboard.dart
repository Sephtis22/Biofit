import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart'; // Your SQLite DB helper
import 'old/homecontent.dart'; // Old user HomeContent
import 'teen/profilecontent.dart'; // Old user ProfileContent
import 'teen/analyticscontent.dart'; // Old user AnalyticsContent
import 'login.dart'; // Login screen

class OldDashboard extends StatefulWidget {
  final String username;

  const OldDashboard({Key? key, required this.username}) : super(key: key);

  @override
  _OldDashboardState createState() => _OldDashboardState();
}

class _OldDashboardState extends State<OldDashboard> {
  int _selectedIndex = 0;
  Map<String, dynamic> userData = {}; // Holds user data from database

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Run on startup
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Load user data from SQLite
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

  // Check login status using shared preferences
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
  Widget build(BuildContext context) {
    if (userData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${userData['fullname']}'),
        backgroundColor: Colors.deepPurple,
      ),
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

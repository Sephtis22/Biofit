import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/database_helper.dart'; // Import your DatabaseHelper class
import '/login.dart'; // Import your login screen

class ProfileContent extends StatefulWidget {
  final String username;

  const ProfileContent({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _userData;
  String? _profileImage; // To store the profile image path
  bool _isPickingImage = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  List<String> _selectedDiseases = [];
  final List<String> _availableDiseases = [
    'Diabetes',
    'Asthma',
    'Heart Disease',
    'Hypertension',
  ];

  bool _isEditing = false; // Track whether we are in editing mode

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data, including profile image
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _fetchUserData() async {
    final dbHelper = DatabaseHelper.instance;
    final user = await dbHelper.getUser(widget.username);
    if (user != null) {
      setState(() {
        _userData = user;
        _profileImage = user['profileImage']; // Load the profile image from database
        _weightController.text = user['weight'].toString();
        _heightController.text = user['height'].toString();
        _selectedDiseases = user['diseaseName']?.split(', ') ?? [];
      });
    }
  }

  Future<void> _selectProfileImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? selectedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        setState(() {
          _profileImage = selectedImage.path; // Update profile image state
        });
        // Save image path to the database
        await _saveProfileImageToDatabase(selectedImage.path);
      }
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _saveProfileImageToDatabase(String imagePath) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.updateUserProfileImage(
      uid: _userData!['uid'],
      profileImage: imagePath,
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveUserData() async {
    if (_validateHeightAndWeight()) {
      final dbHelper = DatabaseHelper.instance;

      // Update user data
      await dbHelper.updateUser(
        uid: _userData!['uid'],
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        hasDisease: _selectedDiseases.isNotEmpty,
        diseaseName: _selectedDiseases.join(', '),
        diseaseDescription: _selectedDiseases.isNotEmpty
            ? "User has selected diseases: ${_selectedDiseases.join(', ')}"
            : '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User details updated successfully!")),
      );

      // Refresh user data after saving
      _fetchUserData();
      setState(() {
        _isEditing = false; // Exit editing mode after saving
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please input valid height and weight!")),
      );
    }
  }

  bool _validateHeightAndWeight() {
    double height = double.tryParse(_heightController.text) ?? 0.0;
    double weight = double.tryParse(_weightController.text) ?? 0.0;

    return height >= 50 && height <= 273 && weight >= 20 && weight <= 635;
  }

  String _calculateBMI() {
    double height = double.tryParse(_heightController.text) ?? 0.0; // Height in cm
    double weight = double.tryParse(_weightController.text) ?? 0.0; // Weight in kg
    if (height > 0) {
      double heightInMeters = height / 100; // Convert height from cm to meters
      double bmi = weight / (heightInMeters * heightInMeters); // Calculate BMI
      return bmi.toStringAsFixed(2); // Keep two decimal places
    }
    return "0.00"; // Fallback in case of invalid height
  }

  @override
  void dispose() {
    _controller.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/prop.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              GestureDetector(
                onTap: () {
                  // Allow the user to select a new profile image
                  _controller.forward();
                  _selectProfileImage();
                  _controller.reverse();
                },
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.15,
                    backgroundColor: Colors.transparent,
                    backgroundImage: _profileImage != null && _profileImage!.isNotEmpty
                        ? FileImage(File(_profileImage!))
                        : const AssetImage('assets/img/default_profile.png') as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _userData!['fullname'] ?? 'Full Name',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Main content container for user data
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255)
                      .withOpacity(0.5), // Transparent background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.person, "Username", _userData!['username']),
                      _buildInfoRow(Icons.cake, "Age", _userData!['age'].toString()),
                      _buildEditableRow(
                          Icons.monitor_weight, "Weight (kg)", _weightController),
                      _buildEditableRow(
                          Icons.height, "Height (cm)", _heightController),
                      _buildBMIRow(),  // BMI row now below height input field
                      _buildGenderRow(Icons.transgender, "Gender", _userData!['gender']),
                      _buildDiseaseDropdown(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 7),
              // Edit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing; // Toggle edit mode
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Personal Data"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              // Save button
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveUserData,
                    child: const Text("Save Changes"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 7),
              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 180, 153, 226),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: const Color.fromARGB(255, 0, 0, 0)),
            const SizedBox(width: 10),
            Text(title, style: titleStyle),
            const SizedBox(width: 10),
            Text(value, style: subtitleStyle),
          ],
        ),
        const Divider(height: 20, thickness: 1, color: Color.fromARGB(255, 246, 250, 250)),
      ],
    );
  }

  Widget _buildEditableRow(IconData icon, String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: const Color.fromARGB(255, 0, 0, 0)),
            const SizedBox(width: 10),
            Text(title, style: titleStyle),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(border: InputBorder.none),
                enabled: _isEditing, // Enable editing if in editing mode
                onChanged: (value) {
                  setState(() {}); // Update state to recalculate BMI when inputs change
                },
              ),
            ),
          ],
        ),
        const Divider(height: 20, thickness: 1, color: Color.fromARGB(255, 246, 250, 250)),
      ],
    );
  }
  Widget _buildBMIRow() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.fitness_center, size: 24, color: Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(width: 10),
          const Text("BMI:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), // Label
          const SizedBox(width: 10), // Spacer between label and value
          Text(
            _calculateBMI(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Value
          ),
        ],
      ),
      const Divider(height: 20, thickness: 1, color: Color.fromARGB(255, 246, 250, 250)),
    ],
  );
}


  Widget _buildGenderRow(IconData icon, String title, String value) {
    return _buildInfoRow(icon, title, value);
  }

  Widget _buildDiseaseDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Diseases:", style: titleStyle),
        DropdownButtonFormField<String>(
          items: _availableDiseases.map((String disease) {
            return DropdownMenuItem<String>(
              value: disease,
              child: Text(disease),
            );
          }).toList(),
          onChanged: _isEditing
              ? (newValue) {
                  setState(() {
                    if (!_selectedDiseases.contains(newValue)) {
                      _selectedDiseases.add(newValue!);
                    }
                  });
                }
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
          hint: const Text("Choose your diseases"),
        ),
        const SizedBox(height: 10),
        // Display selected diseases as chips
        Wrap(
          children: _selectedDiseases.map((disease) {
            return Chip(
              label: Text(disease),
              onDeleted: _isEditing
                  ? () {
                      setState(() {
                        _selectedDiseases.remove(disease);
                      });
                    }
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

const titleStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
const subtitleStyle = TextStyle(fontSize: 18);
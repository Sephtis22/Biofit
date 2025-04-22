import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For Date formatting
import 'database_helper.dart'; // Assuming you're handling the database
import 'login.dart'; // Assuming you have a login screen to navigate after registration

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  double? _bmi;
  List<String> _selectedDiseases = [];
  String? _profileImagePath;

  final List<String> _diseaseOptions = [
    "Diabetes",
    "Hypertension",
    "Asthma",
    "Heart Disease",
  ];

  String? _fullnameError, _usernameError, _passwordError, _confirmPasswordError;
  String? _weightError, _heightError, _ageError, _genderError;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_calculateBMI);
    _heightController.addListener(_calculateBMI);
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _ageError = null; // Reset age error when a date is selected
      });
    }
  }

  void _calculateBMI() {
    double? weight = double.tryParse(_weightController.text);
    double? height = double.tryParse(_heightController.text);
    if (weight != null && height != null && height > 0) {
      setState(() {
        _bmi = weight / ((height / 100) * (height / 100));
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _fullnameError = _validateFullName(_fullnameController.text);
      _usernameError = _validateUsername(_usernameController.text);
      _passwordError = _passwordController.text.length < 6 ? "Password must be at least 6 characters." : null;
      _confirmPasswordError = _passwordController.text != _confirmPasswordController.text ? "Passwords do not match." : null;
      _weightError = _validateWeight(double.tryParse(_weightController.text));
      _heightError = _validateHeight(double.tryParse(_heightController.text));
      _ageError = _validateAge(); // Validate age based on selected date
      _genderError = _selectedGender == null ? "Select your gender." : null;
    });

    if (_fullnameError == null &&
        _usernameError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _weightError == null &&
        _heightError == null &&
        _ageError == null &&
        _genderError == null) {

      final dbHelper = DatabaseHelper.instance;

      await dbHelper.insertUser(
        fullname: _fullnameController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        age: DateTime.now().year - _selectedDate!.year,
        gender: _selectedGender!,
        bmi: _bmi ?? 0,
        hasDisease: _selectedDiseases.isNotEmpty, // Pass whether the user has any diseases
        diseaseName: _selectedDiseases.isNotEmpty ? _selectedDiseases.join(', ') : '', // If there are diseases, join them into a string
        diseaseDescription: _selectedDiseases.isNotEmpty ? "User has selected the following diseases: ${_selectedDiseases.join(', ')}" : '', // Description of selected diseases
        profileImage: _profileImagePath ?? 'default/path/to/profile/image.png', // Default if no image is picked
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Registration successful! Please log in.")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  String? _validateFullName(String value) {
    if (value.isEmpty) {
      return "Full name is required.";
    }
    if (RegExp(r'\d').hasMatch(value)) {
      return "Full name cannot contain numbers.";
    }
    return null;
  }

  String? _validateUsername(String value) {
    if (value.isEmpty) {
      return "Username is required.";
    }
    if (!RegExp(r'^[A-Za-z]').hasMatch(value)) {
      return "Username must start with a letter.";
    }
    return null;
  }

  String? _validateWeight(double? weight) {
    if (weight == null || weight <= 0) {
      return "Weight is required.";
    }
    if (weight < 20 || weight > 300) {
      return "Weight must be between 20 kg and 300 kg.";
    }
    return null;
  }

  String? _validateHeight(double? height) {
    if (height == null || height <= 0) {
      return "Height is required.";
    }
    if (height < 50 || height > 251) {
      return "Height must be between 50 cm and 251 cm.";
    }
    return null;
  }

  String? _validateAge() {
    if (_selectedDate == null) {
      return "Select your birthdate.";
    }
    int age = DateTime.now().year - _selectedDate!.year;
    if (age < 9 || age > 99) {
      return "Age must be between 9 and 99 years.";
    }
    return null;
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? errorText, {
    bool isPassword = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          errorText: errorText,
        ),
      ),
    );
  }

  Widget _buildDiseaseSelection() {
    return Wrap(
      children: _diseaseOptions.map((disease) {
        return ChoiceChip(
          label: Text(disease),
          selected: _selectedDiseases.contains(disease),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDiseases.add(disease);
              } else {
                _selectedDiseases.remove(disease);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: "Gender",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: ["Male", "Female"].map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (newValue) => setState(() {
        _selectedGender = newValue;
        _genderError = null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.person_add, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 10),
              const Text(
                "Create an Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),
              _buildTextField(_fullnameController, "Full Name", Icons.person_outline, _fullnameError),
              _buildTextField(_usernameController, "Username", Icons.person, _usernameError),
              _buildTextField(_passwordController, "Password", Icons.lock, _passwordError, isPassword: true),
              _buildTextField(_confirmPasswordController, "Confirm Password", Icons.lock, _confirmPasswordError, isPassword: true),
              _buildTextField(_weightController, "Weight (kg)", Icons.monitor_weight, _weightError, isNumber: true),
              _buildTextField(_heightController, "Height (cm)", Icons.height, _heightError, isNumber: true),

              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    TextEditingController(
                      text: _selectedDate == null ? "" : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    ),
                    "Select Age",
                    Icons.calendar_today,
                    _ageError,
                  ),
                ),
              ),
              _buildDropdown(),
              const SizedBox(height: 10),
              _buildDiseaseSelection(),
              const SizedBox(height: 20),
              if (_bmi != null)
                Text("BMI: ${_bmi!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _submit,
                  child: const Text("Submit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
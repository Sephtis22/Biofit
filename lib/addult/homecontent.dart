import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '/addultExercise/cardio.dart';
import '/addultExercise/legs.dart';
import '/addultExercise/arms.dart';
import '/addultExercise/yoga.dart';
import '/database_helper.dart';
import '../teen/advicedb.dart';
import 'package:lottie/lottie.dart';






class HomeContent extends StatefulWidget {
  final String username;

  const HomeContent({Key? key, required this.username}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String fullName = "User";
  String? diseaseName;
  String? diseaseDescription;
  DateTime selectedDate = DateTime.now();
  Map<String, bool> expandedStates = {};
  bool isParentExpanded = false;

  final Map<String, String> diseaseDescriptions = {
    "Asthma": "Asthma is a chronic condition that inflames and narrows the airways, causing wheezing, shortness of breath, and coughing. Exercise may need to be modified to prevent triggering symptoms.",
    "Diabetes": "Diabetes affects the body’s ability to process blood glucose. Regular low-impact exercises like walking or yoga can help maintain blood sugar levels.",
    "Hypertension": "Hypertension, or high blood pressure, increases the risk of heart disease. Cardiovascular exercises and a healthy diet can help manage it.",
    "Heart Disease": "Heart disease encompasses conditions that affect heart function. Low-intensity workouts with proper medical supervision are recommended.",
  };

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final dbHelper = DatabaseHelper.instance;
    final user = await dbHelper.getUser(widget.username);

    if (user != null) {
      setState(() {
        fullName = user['fullname'] ?? "User";
        diseaseName = user['diseaseName'];
        diseaseDescription = user['diseaseDescription'];

        if (diseaseName != null) {
          for (var disease in diseaseName!.split(',').map((d) => d.trim())) {
            expandedStates[disease] = false;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLocked = diseaseName != null && diseaseName!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[300]!, Colors.blue[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome, $fullName!",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900])),
                    SizedBox(height: 8),
                    Text("Here are the best exercises we provide.",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800])),
                    SizedBox(height: 4),
                    Text("Take your exercise and enjoy it!",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (diseaseName != null && diseaseName!.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() => isParentExpanded = !isParentExpanded);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.health_and_safety,
                                color: Colors.red[800]),
                            SizedBox(width: 8),
                            Text("Tap to view health note",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[800])),
                          ],
                        ),
                        if (isParentExpanded)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...diseaseName!.split(',').map((disease) {
                                final trimmed = disease.trim();
                                final description =
                                    diseaseDescriptions[trimmed] ??
                                        "No description available.";

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      expandedStates[trimmed] =
                                          !(expandedStates[trimmed] ?? false);
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    margin: EdgeInsets.only(top: 12),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.redAccent),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Lottie.asset("assets/lottie/sakit.json"),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(trimmed,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.red[800])),
                                              if (expandedStates[trimmed] ?? false) ...[
                                                SizedBox(height: 8),
                                                Text(description,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black)),
                                              ] else
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(top: 4.0),
                                                  child: Text(
                                                    "Tap to view description",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.red[700]),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                             SizedBox(height: 16),
                           Center(
                         child: ElevatedButton.icon(
                         onPressed: () {
                        Navigator.push(
                        context,
                     MaterialPageRoute(
                   builder: (context) => AdviceDashboard(),
             ),
           );
       },
         style: ElevatedButton.styleFrom(
      backgroundColor: Colors.redAccent,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    icon: Icon(Icons.health_and_safety, color: Colors.white),
    label: Text(
      "Professional Advice",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 20),
              Text("Discover new workouts",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Column(
                children: [
                  _buildWorkoutCard("Strength training", "3 Exercises\n50 Minutes", "assets/img/strength.jpg", context, CardioPage(), isLocked),
                  SizedBox(height: 16),
                  _buildWorkoutCard("Cardio ", "3 Exercises\n35 Minutes", "assets/img/cardios.webp", context, ArmsPage(), isLocked),
                  SizedBox(height: 16),
                  _buildWorkoutCard("core exercise", "3 Exercises\n40 Minutes", "assets/img/core.jpg", context, LegsPage(), isLocked),
                  SizedBox(height: 16),
                  _buildWorkoutCard("Flexibility and mobility", "6 Exercises\n45 Minutes", "assets/img/flexibility.jpg", context, YogaPage(), false),
                ],
              ),
              SizedBox(height: 20),
              Text("Calendar",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[100]!, Colors.blue[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: TableCalendar(
                  focusedDay: selectedDate,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() => selectedDate = selectedDay);
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration:
                        BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    todayDecoration:
                        BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(Icons.chevron_left),
                    rightChevronIcon: Icon(Icons.chevron_right),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 40, color: Colors.orange),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Keep the progress!",
                            style:
                                TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text("You are more successful\nthan 88% of users."),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(String title, String details, String imagePath,
      BuildContext context, Widget page, bool isLocked) {
    return GestureDetector(
      onTap: isLocked
          ? null
          : () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => page)),
      child: Stack(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                  image: AssetImage(imagePath), fit: BoxFit.cover),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
            ),
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(details,
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ),
          if (isLocked)
            Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.lock, color: Colors.red, size: 30),
            ),
          if (isLocked)
            Positioned(
              bottom: 10,
              left: 10,
              child: Text(
                "Locked due to health condition",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}

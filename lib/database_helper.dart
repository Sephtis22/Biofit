import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'teen/analytics_data_model.dart'; // Replace with the correct path to your AnalyticsData model

// Database Helper class
class DatabaseHelper {
  static const _databaseName = "users.db";
  static const _databaseVersion = 3; // Increment version for schema changes

  // Users Table
  static const table = 'users';
  static const columnId = 'uid';
  static const columnUsername = 'username';
  static const columnPassword = 'password';
  static const columnFullname = 'fullname';
  static const columnAge = 'age';
  static const columnGender = 'gender';
  static const columnWeight = 'weight';
  static const columnHeight = 'height';
  static const columnBmi = 'bmi';
  static const columnHasDisease = 'hasDisease'; // Indicates if the user has any diseases
  static const columnDiseaseName = 'diseaseName'; // Name of the disease
  static const columnDiseaseDescription = 'diseaseDescription'; // Description of the disease
  static const columnProfileImage = 'profileImage'; // Profile image path

  // Analytics Table
  static const analyticsTable = 'analytics';
  static const analyticsColumnId = 'id';
  static const analyticsColumnTimeSpent = 'timeSpent';
  static const analyticsColumnCaloriesBurned = 'caloriesBurned';
  static const analyticsColumnWorkoutCount = 'workoutCount';

  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Open database or create it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle upgrades if needed
    );
  }

  // Create tables
  Future _onCreate(Database db, int version) async {
    await db.execute('''    
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUsername TEXT NOT NULL UNIQUE,
        $columnPassword TEXT NOT NULL,
        $columnFullname TEXT NOT NULL,
        $columnAge INTEGER NOT NULL,
        $columnGender TEXT NOT NULL,
        $columnWeight REAL NOT NULL,
        $columnHeight REAL NOT NULL,
        $columnBmi REAL NOT NULL,
        $columnHasDisease INTEGER NOT NULL DEFAULT 0,
        $columnDiseaseName TEXT,
        $columnDiseaseDescription TEXT,
        $columnProfileImage TEXT
      )
    ''');

    // Analytics Table
    await db.execute('''    
      CREATE TABLE $analyticsTable (
        $analyticsColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $analyticsColumnTimeSpent INTEGER NOT NULL,
        $analyticsColumnCaloriesBurned INTEGER NOT NULL,
        $analyticsColumnWorkoutCount INTEGER NOT NULL
      )
    ''');
  }

  // Handle database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''    
        ALTER TABLE $table ADD COLUMN $columnHasDisease INTEGER NOT NULL DEFAULT 0
      ''');
      await db.execute('''    
        ALTER TABLE $table ADD COLUMN $columnDiseaseName TEXT
      ''');
      await db.execute('''    
        ALTER TABLE $table ADD COLUMN $columnDiseaseDescription TEXT
      ''');
    }
    if (oldVersion < 3) {
      // Add the profileImage column only if it does not exist
      try {
        await db.execute('ALTER TABLE $table ADD COLUMN $columnProfileImage TEXT');
      } catch (e) {
        // Handle the exception if the column already exists
        print("Column '$columnProfileImage' already exists: $e");
      }
    }
  }

  // Insert a new user
  Future<int> insertUser({
    required String fullname,
    required String username,
    required String password,
    required double weight,
    required double height,
    required int age,
    required String gender,
    required double bmi,
    required bool hasDisease,
    required String diseaseName,
    required String diseaseDescription,
    required String profileImage,
  }) async {
    Database db = await instance.database;

    // Hash the password
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    final user = {
      columnFullname: fullname,
      columnUsername: username,
      columnPassword: hashedPassword,
      columnAge: age,
      columnGender: gender,
      columnWeight: weight,
      columnHeight: height,
      columnBmi: bmi,
      columnHasDisease: hasDisease ? 1 : 0, // Store as 1 (true) or 0 (false)
      columnDiseaseName: diseaseName,
      columnDiseaseDescription: diseaseDescription,
      columnProfileImage: profileImage, // Store the profile image path
    };

    return await db.insert(table, user);
  }

  // Update an existing user
  Future<int> updateUser({
    required int uid,
    required double weight,
    required double height,
    required bool hasDisease,
    required String diseaseName,
    required String diseaseDescription,
  }) async {
    Database db = await instance.database;

    final valuesToUpdate = {
      columnWeight: weight,
      columnHeight: height,
      columnHasDisease: hasDisease ? 1 : 0,
      columnDiseaseName: diseaseName,
      columnDiseaseDescription: diseaseDescription,
    };

    return await db.update(
      table,
      valuesToUpdate,
      where: '$columnId = ?',
      whereArgs: [uid],
    );
  }

  // Update the user's profile image
  Future<int> updateUserProfileImage({
    required int uid,
    required String profileImage,
  }) async {
    Database db = await instance.database;

    final valuesToUpdate = {
      columnProfileImage: profileImage,
    };

    return await db.update(
      table,
      valuesToUpdate,
      where: '$columnId = ?',
      whereArgs: [uid],
    );
  }

  // Get a user by username
  Future<Map<String, dynamic>?> getUser(String username) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      table,
      where: '$columnUsername = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      final user = result.first;
      return {
        ...user,
        'hasDisease': user[columnHasDisease] == 1, // Convert from integer to boolean
      };
    }
    return null; // Return null if user is not found
  }

  // Insert or update analytics data
  Future<void> insertOrUpdateAnalytics(AnalyticsData data) async {
    final db = await database; // Get database instance

    final List<Map<String, dynamic>> existingData = await db.query(
      analyticsTable,
      where: '$analyticsColumnId = ?',
      whereArgs: [1], // We maintain a single record for simplicity
    );

    if (existingData.isNotEmpty) {
      final existingAnalytics = AnalyticsData(
        id: existingData[0][analyticsColumnId],
        timeSpent: existingData[0][analyticsColumnTimeSpent],
        caloriesBurned: existingData[0][analyticsColumnCaloriesBurned],
        workoutCount: existingData[0][analyticsColumnWorkoutCount],
      );

      final updatedAnalytics = AnalyticsData(
        id: existingAnalytics.id,
        timeSpent: existingAnalytics.timeSpent + data.timeSpent,
        caloriesBurned: existingAnalytics.caloriesBurned + data.caloriesBurned,
        workoutCount: existingAnalytics.workoutCount + 1,
      );

      await db.update(
        analyticsTable,
        updatedAnalytics.toMap(),
        where: '$analyticsColumnId = ?',
        whereArgs: [1],
      );
    } else {
      await db.insert(
        analyticsTable,
        data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, // If the record exists, replace it
      );
    }
  }

  // Get all analytics data
  Future<List<AnalyticsData>> getAnalyticsData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(analyticsTable);

    return List.generate(maps.length, (i) {
      return AnalyticsData(
        id: maps[i][analyticsColumnId],
        timeSpent: maps[i][analyticsColumnTimeSpent],
        caloriesBurned: maps[i][analyticsColumnCaloriesBurned],
        workoutCount: maps[i][analyticsColumnWorkoutCount],
      );
    });
  }
}
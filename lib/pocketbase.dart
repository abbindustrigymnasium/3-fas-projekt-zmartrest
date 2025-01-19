import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:zmartrest/app_constants.dart';

SharedPreferences? prefs;
final pb = PocketBase(pocketbaseUrl, authStore: store);

Future<void> initPrefs() async {
  debugPrint('Initializing prefs...');
  prefs = await SharedPreferences.getInstance();
  debugPrint('Prefs initialized');
}

final store = AsyncAuthStore(
  save:    (String data) async => prefs?.setString('pb_auth', data),
  initial: prefs?.getString('pb_auth'),
);

Future<ThemeMode> loadThemeFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final themeString = prefs.getString('theme') ?? 'light';
  return themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
}

Future<void> saveThemeToPrefs(String theme) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('theme', theme);
}

authenticateUser(String email, String password) async {
  // Authenticate the user
  try {
    final authData = await pb.collection('users').authWithPassword(
      email,
      password,
    );

    debugPrint('FULL AUTH DATA: $authData');

    /*

    final userData = authData.record;
    final userMap = userData.data;

    // Fetch data with timestamp range
    int timestampFrom = 1734013000;
    int timestampTo = 1734014000;

    // Fetch all data within the range
    await fetchAllDataFromTo(pb, userMap['id'], timestampFrom, timestampTo);

    */

    return true;
  } catch (e) {
    debugPrint('Error during authentication: $e');
  }
}

Future<bool> isUserAuthenticated() async {
  try {
    final valid = pb.authStore.isValid; // Checks if the session is valid

    if (!valid) {
      debugPrint('User is not authenticated, needs to be logged in');
      return false;
    } else {
      debugPrint('User is authenticated');
      return true;
    }
  } catch (e) {
    debugPrint('Error checking session validity: $e');
    return false;
  }
}

Future<Map<String, dynamic>?> getUserInfo() async {
  try {
    // Check if the user is authenticated by accessing the authenticated user record
    final authData = pb.authStore.record;

    if (authData == null) {
      debugPrint('User is not authenticated');
      return null;  // Return null if the user is not authenticated
    }

    final userId = authData.id;

    // Fetch user information using userId
    final userRecord = await pb.collection('users').getOne(userId);

    // Map the user data to a readable format
    final userInfo = {
      'id': userRecord.id,
      'email': userRecord.data['email'],
      'username': userRecord.data['name'],
      'created': userRecord.data['created'],
      'updated': userRecord.data['updated'],
    };

    return userInfo;
  } catch (e) {
    debugPrint('Error fetching user info: $e');
    return null;  // Return null in case of error
  }
}

void logout() async {
  try {
    // Clear the auth session
    pb.authStore.clear();
    debugPrint('User logged out successfully.');
  } catch (e) {
    debugPrint('Error during logout: $e');
  }
}

// Add accelerometer data to PocketBase
Future<void> addAccelerometerData(
  PocketBase pb,
  String userId,
  int timestamp,
  List accelerometerList,
) async {
  try {
    final accelerometerData = {
      'timestamp': timestamp,
      'x': accelerometerList[0],
      'y': accelerometerList[1],
      'z': accelerometerList[2],
      'user': userId,
    };

    final result = await pb.collection('accelerometer_data').create(body: accelerometerData);
    debugPrint('Accelerometer data added:');
    debugPrint(result.toJson().toString());
  } catch (e) {
    debugPrint('Error adding accelerometer data: $e');
  }
}

// Add heart rate data to PocketBase
Future<void> addHeartrateData(
  PocketBase pb,
  String userId,
  int timestamp,
  List heartrateList,
) async {
  try {
    final heartrateData = {
      'timestamp': timestamp,
      'hr': heartrateList[0],
      //'hrv': heartrateList[1],
      //'r_r': heartrateList[2],
      'user': userId
    };

    final result =
        await pb.collection('heart_rate_data').create(body: heartrateData);
    debugPrint('Heart rate data added:');
    debugPrint(result.toJson().toString());
  } catch (e) {
    debugPrint('Error adding heart rate data: $e');
  }
}

Future<void> addRmssdData(
  PocketBase pb,
  String userId,
  int timestamp, 
  double rmssd
) async {
  try {
    final rmssdData = {
      'user': userId,
      'timestamp': timestamp,
      'rmssd': rmssd,
    };

    final result =
        await pb.collection('rmssd_data').create(body: rmssdData);
    debugPrint('RMSSD data added:');
    debugPrint(result.toJson().toString());
  } catch (e) {
    debugPrint('Error adding RMSSD data: $e');
  }
}

Future<void> addRmssdBaselineData(
  PocketBase pb,
  String userId,
  int timestamp, 
  double? rmssdBaseline
) async {
  try {
    final rmssdBaselineData = {
      'user': userId,
      'timestamp': timestamp,
      'rmssd_baseline': rmssdBaseline,
    };

    final result =
        await pb.collection('rmssd_baseline_data').create(body: rmssdBaselineData);
    debugPrint('RMSSD data added:');
    debugPrint(result.toJson().toString());
  } catch (e) {
    debugPrint('Error adding RMSSD data: $e');
  }
}

// Fetch accelerometer data for a specific user within a timestamp range
Future<List<Map<String, dynamic>>> fetchAccelerometerData(
    PocketBase pb, String userId, int timestampFrom, int timestampTo) async {
  try {
    final result = await pb.collection('accelerometer_data').getList(
      page: 1,
      perPage: 10,
      filter:
          'user = "$userId" && timestamp >= $timestampFrom && timestamp <= $timestampTo',
    );

    List<Map<String, dynamic>> dataList = result.items.map((record) {
      return {
        'timestamp': record.data['timestamp'],
        'x': record.data['x'],
        'y': record.data['y'],
        'z': record.data['z'],
        'user': record.data['user'],
      };
    }).toList();

    debugPrint('Fetched accelerometer data within range');
    /*
    for (var data in dataList) {
      debugPrint(data.toString());
    }
    */

    return dataList;
  } catch (e) {
    debugPrint('Failed to fetch accelerometer data: $e');
    return [];
  }
}

// Fetch heart rate data for a specific user within a timestamp range
Future<List<Map<String, dynamic>>> fetchHeartrateData(
    PocketBase pb, String userId, int timestampFrom, int timestampTo) async {
  try {
    final result = await pb.collection('heart_rate_data').getList(
      page: 1,
      perPage: 10,
      filter:
          'user = "$userId" && timestamp >= $timestampFrom && timestamp <= $timestampTo',
    );

    List<Map<String, dynamic>> dataList = result.items.map((record) {
      return {
        'timestamp': record.data['timestamp'],
        'hr': record.data['hr'],
        'hrv': record.data['hrv'],
        'r_r': record.data['r_r'],
        'user': record.data['user'],
      };
    }).toList();

    debugPrint('Fetched heart rate data within range');
    /*
    for (var data in dataList) {
      debugPrint(data.toString());
    }
    */

    return dataList;
  } catch (e) {
    debugPrint('Failed to fetch heart rate data: $e');
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchRmssdData(
    PocketBase pb, String userId, int timestampFrom, int timestampTo) async {
  try {
    final result = await pb.collection('rmssd_data').getList(
      page: 1,
      perPage: 10,
      filter:
          'user = "$userId" && timestamp >= $timestampFrom && timestamp <= $timestampTo',
    );

    List<Map<String, dynamic>> dataList = result.items.map((record) {
      return {
        'timestamp': record.data['timestamp'],
        'rmssd': record.data['rmssd'],
        'user': record.data['user'],
      };
    }).toList();

    debugPrint('Fetched rmssd data within range');
    /*
    for (var data in dataList) {
      debugPrint(data.toString());
    }
    */

    return dataList;
  } catch (e) {
    debugPrint('Failed to fetch rmssd data: $e');
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchRmssdBaselineData(
    PocketBase pb, String userId, int timestampFrom, int timestampTo) async {
  try {
    final result = await pb.collection('rmssd_baseline_data').getList(
      page: 1,
      perPage: 10,
      filter:
          'user = "$userId" && timestamp >= $timestampFrom && timestamp <= $timestampTo',
    );

    List<Map<String, dynamic>> dataList = result.items.map((record) {
      return {
        'timestamp': record.data['timestamp'],
        'rmssd': record.data['rmssd_baseline'],
        'user': record.data['user'],
      };
    }).toList();

    debugPrint('Fetched rmssd baseline data within range');
    /*
    for (var data in dataList) {
      debugPrint(data.toString());
    }
    */

    return dataList;
  } catch (e) {
    debugPrint('Failed to fetch rmssd baseline data: $e');
    return [];
  }
}


// Fetch all data (accelerometer + heart rate) within a timestamp range
Future fetchAllDataFromTo(PocketBase pb, String userId, int timestampFrom, int timestampTo) async {
  debugPrint('Fetching all data within range...');
  final accelerometerData =
    await fetchAccelerometerData(pb, userId, timestampFrom, timestampTo);
  final heartrateData =
    await fetchHeartrateData(pb, userId, timestampFrom, timestampTo);
  final rmssdData =
    await fetchRmssdData(pb, userId, timestampFrom, timestampTo);
  final rmssdBaselineData =
    await fetchRmssdBaselineData(pb, userId, timestampFrom, timestampTo);

  return {
    'accelerometer': accelerometerData,
    'heartrate': heartrateData,
    'rmssd': rmssdData,
    'rmssd_baseline': rmssdBaselineData,
  };
}

Future<List<Map<String, dynamic>>> fetchAllUsers(PocketBase pb) async {
  try {
    final result = await pb.collection('users').getList(
      page: 1,
      perPage: 100,
    );

    List<Map<String, dynamic>> users = result.items.map((record) {
      return {
        'id': record.id,
        'name': record.data['name'] ?? '',
        'email': record.data['email'] ?? '',
      };
    }).toList();

    debugPrint('Fetched ${users.length} users');
    return users;
  } catch (e) {
    debugPrint('Error fetching users: $e');
    return []; // Return empty list in case of error
  }
}

// Get the latest day that has data
Future<DateTime> getLatestDataDate() async {
  try {
    // Fetch the most recent record from each collection
    final latestAccelerometer = await pb.collection('accelerometer_data').getList(
      page: 1,
      perPage: 1,
      sort: '-timestamp', // Sort in descending order by timestamp
    );
    final latestHeartrate = await pb.collection('heart_rate_data').getList(
      page: 1,
      perPage: 1,
      sort: '-timestamp', // Sort in descending order by timestamp
    );
    final latestRmssd = await pb.collection('rmssd_data').getList(
      page: 1,
      perPage: 1,
      sort: '-timestamp', // Sort in descending order by timestamp
    );
    final latestRmssdBaseline = await pb.collection('rmssd_baseline_data').getList(
      page: 1,
      perPage: 1,
      sort: '-timestamp', // Sort in descending order by timestamp
    );

    // Find the latest timestamp from all the data collections
    int latestTimestamp = 0;

    if (latestAccelerometer.items.isNotEmpty) {
      latestTimestamp = latestAccelerometer.items[0].data['timestamp'];
    }
    if (latestHeartrate.items.isNotEmpty) {
      latestTimestamp = latestTimestamp > latestHeartrate.items[0].data['timestamp']
          ? latestTimestamp
          : latestHeartrate.items[0].data['timestamp'];
    }
    if (latestRmssd.items.isNotEmpty) {
      latestTimestamp = latestTimestamp > latestRmssd.items[0].data['timestamp']
          ? latestTimestamp
          : latestRmssd.items[0].data['timestamp'];
    }
    if (latestRmssdBaseline.items.isNotEmpty) {
      latestTimestamp = latestTimestamp > latestRmssdBaseline.items[0].data['timestamp']
          ? latestTimestamp
          : latestRmssdBaseline.items[0].data['timestamp'];
    }

    // Return the latest date
    return DateTime.fromMillisecondsSinceEpoch(latestTimestamp * 1000);
  } catch (e) {
    debugPrint('Error fetching latest data date: $e');
    return DateTime(2000); // Default to a far past date if error occurs
  }
}

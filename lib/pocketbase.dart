//Needed things from outside = timestampFrom and timestampTo
//Functions needs list<map<string, dynamic>>> and returns the same

import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('https://zmartrest-pb.superdator.spetsen.net/');

authenticateUser(String email, String password) async {
  // Authenticate the user
  try {
    final authData = await pb.collection('users').authWithPassword(
      email,
      password,
    );
    final userData = authData.record;
    final userMap = userData.data;

    print('User authenticated:');
    print('ID: ${userMap['id']}');
    print('Email: ${userMap['email']}');

    /*
    // Test data
    await addHeartrateData(pb, userMap['id'], 1734013490, [80, 10, 850]);
    await addHeartrateData(pb, userMap['id'], 1734013385, [75, 5, 800]);
    await addHeartrateData(pb, userMap['id'], 1734013270, [78, 8, 810]);
    await addHeartrateData(pb, userMap['id'], 1734013150, [82, 12, 870]);
    await addHeartrateData(pb, userMap['id'], 1734013000, [77, 7, 780]);
    await addHeartrateData(pb, userMap['id'], 1734012905, [79, 6, 820]);
    await addHeartrateData(pb, userMap['id'], 1734012780, [83, 9, 860]);
    await addHeartrateData(pb, userMap['id'], 1734012650, [76, 4, 790]);
    await addHeartrateData(pb, userMap['id'], 1734012505, [81, 11, 840]);
    await addHeartrateData(pb, userMap['id'], 1734012390, [74, 3, 770]);
    await addHeartrateData(pb, userMap['id'], 1734012280, [79, 10, 830]);
    await addHeartrateData(pb, userMap['id'], 1734012175, [80, 8, 850]);
    await addHeartrateData(pb, userMap['id'], 1734012050, [76, 6, 780]);
    await addHeartrateData(pb, userMap['id'], 1734011930, [84, 7, 880]);
    await addHeartrateData(pb, userMap['id'], 1734011805, [75, 5, 800]);
    await addHeartrateData(pb, userMap['id'], 1734011690, [81, 9, 840]);
    await addHeartrateData(pb, userMap['id'], 1734011570, [78, 8, 810]);
    await addHeartrateData(pb, userMap['id'], 1734011450, [83, 6, 860]);
    */

    // Fetch data with timestamp range
    int timestampFrom = 1734013000;
    int timestampTo = 1734014000;

    await fetchAccelerometerData(pb, userMap['id'], timestampFrom, timestampTo);
    await fetchHeartrateData(pb, userMap['id'], timestampFrom, timestampTo);

    // Fetch all data within the range
    await fetchAllDataFromTo(pb, userMap['id'], timestampFrom, timestampTo);

    return true;
  } catch (e) {
    print('Error during authentication: $e');
  }
}

Future<Map<String, dynamic>?> getUserInfo() async {
  try {
    // Check if the user is authenticated by accessing the authenticated user record
    final authData = pb.authStore.record;

    if (authData == null) {
      print('User is not authenticated');
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
      // Add any other fields you want to retrieve
    };

    return userInfo;
  } catch (e) {
    print('Error fetching user info: $e');
    return null;  // Return null in case of error
  }
}

void logout() {
  try {
    // Clear the auth session
    pb.authStore.clear();
    print('User logged out successfully.');
  } catch (e) {
    print('Error during logout: $e');
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

    final result =
        await pb.collection('accelerometer_data').create(body: accelerometerData);
    print('Accelerometer data added:');
    print(result.toJson());
  } catch (e) {
    print('Error adding accelerometer data: $e');
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
      'hrv': heartrateList[1],
      'r_r': heartrateList[2],
      'user': userId
    };

    final result =
        await pb.collection('heart_rate_data').create(body: heartrateData);
    print('Heart rate data added:');
    print(result.toJson());
  } catch (e) {
    print('Error adding heart rate data: $e');
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

    print('Fetched accelerometer data within range:');
    for (var data in dataList) {
      print(data);
    }

    return dataList;
  } catch (e) {
    print('Failed to fetch accelerometer data: $e');
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

    print('Fetched heart rate data within range:');
    for (var data in dataList) {
      print(data);
    }

    return dataList;
  } catch (e) {
    print('Failed to fetch heart rate data: $e');
    return [];
  }
}

// Fetch all data (accelerometer + heart rate) within a timestamp range
Future fetchAllDataFromTo(PocketBase pb, String userId, int timestampFrom, int timestampTo) async {
  print('Fetching all data within range...');
  final accelerometerData =
    await fetchAccelerometerData(pb, userId, timestampFrom, timestampTo);
  final heartrateData =
    await fetchHeartrateData(pb, userId, timestampFrom, timestampTo);

  return {
    'accelerometer': accelerometerData,
    'heartrate': heartrateData,
  };

  /*
  print('Combined data within range:');
  print('Accelerometer Data:');
  for (var data in accelerometerData) {
    print(data);
  }

  print('Heart Rate Data:');
  for (var data in heartrateData) {
    print(data);
  }
  */
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

    print('Fetched ${users.length} users');
    return users;
  } catch (e) {
    print('Error fetching users: $e');
    return []; // Return empty list in case of error
  }
}
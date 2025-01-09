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

    // Example accelerometer and heart rate lists
    List examplelistOrg = [-2, 5, -10];
    List examplelist_heart = [75, 5, 800];

    // Add example data
    await addAccelerometerData(pb, userMap['id'], 1734013485, examplelistOrg);
    await addHeartrateData(pb, userMap['id'], 1734013485, examplelist_heart);

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
        'name': record.data['username'] ?? '',
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
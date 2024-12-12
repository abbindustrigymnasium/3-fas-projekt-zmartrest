import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://zmartrest-pb.cloud.spetsen.net/');

  // Authenticate the user
  try {
    final authData = await pb.collection('users').authWithPassword(
      'alwin.forslund@hitachigymnasiet.se',
      'Jagälskarspetsen',
    );
    final userData = authData.record;
    final userMap = userData.data;

    print('User authenticated:');
    print('ID: ${userMap['id']}');
    print('Email: ${userMap['email']}');

    // Add accelerometer data
    //await addAccelerometerData(pb, userMap['id'], 1633046400, 0.45, -0.23, 9.81); // Example 1
    //await addAccelerometerData(pb, userMap['id'], 1633046500, 0.50, -0.30, 9.82); // Example 2

    // Fetch accelerometer data for the user
    //await fetchAccelerometerData(pb, userMap['id']);

    // Fetch all data from a specific time range
    await fetchAllDataFromTo(pb, userMap['id'], 0, 1833047000);
  } catch (e) {
    print('Error during authentication: $e');
  }
}

// Data model for AccelerometerData
class AccelerometerData {
  final String id;
  final String user;
  final int timestamp;
  final double x;
  final double y;
  final double z;

  AccelerometerData({
    required this.id,
    required this.user,
    required this.timestamp,
    required this.x,
    required this.y,
    required this.z,
  });

  factory AccelerometerData.fromRecord(dynamic record) {
    return AccelerometerData(
      id: record.id,
      user: record.data['user'],
      timestamp: record.data['timestamp'],
      x: record.data['x'],
      y: record.data['y'],
      z: record.data['z'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'timestamp': timestamp,
      'x': x,
      'y': y,
      'z': z,
    };
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
    print('Accelerometer data added:');
    print(result.toJson());
  } catch (e) {
    print('Error adding accelerometer data: $e');
  }
}

// Fetch accelerometer data for a specific user
Future<void> fetchAccelerometerData(PocketBase pb, String userId) async {
  try {
    final result = await pb.collection('accelerometer_data').getList(
      page: 1,
      perPage: 10,
      filter: 'user = "$userId"', // Filter by user ID
    );

    print('Fetched accelerometer data for user:');
    for (var record in result.items) {
      print('Timestamp: ${record.data['timestamp']}, X: ${record.data['x']}, Y: ${record.data['y']}, Z: ${record.data['z']}');
    }
  } catch (e) {
    print('Failed to fetch accelerometer data: $e');
  }
}

// Enhanced function to fetch data from multiple collections
Future<Map<String, List<dynamic>>> fetchAllDataFromTo(
    PocketBase pb, String userId, int timestampFrom, int timestampTo) async {
  try {
    print("Fetching all data from $timestampFrom to $timestampTo");

    // Create a map to store results from different collections
    Map<String, List<dynamic>> allData = {};

    // List of collections you want to fetch from
    List<String> collections = [
      "accelerometer_data",
      // Add other collection names here if needed
    ];

    // Fetch data for each collection
    for (var collectionName in collections) {
      var result = await pb.collection(collectionName).getList(
        filter: 'user = "$userId" && timestamp >= $timestampFrom && timestamp <= $timestampTo',
        page: 1,
        perPage: 100, // Adjust as needed
      );

      // Map records to specific data models
      List<dynamic> mappedItems = result.items.map((item) {
        if (collectionName == 'accelerometer_data') {
          return AccelerometerData.fromRecord(item);
        }
        // Add more mappings for other collections
        return item;
      }).toList();

      allData[collectionName] = mappedItems;
    }

    // Print total records fetched from each collection
    allData.forEach((collection, items) {
      print('Fetched ${items.length} items from $collection');
      
      // Detailed printing for accelerometer data
      if (collection == 'accelerometer_data') {
        for (var data in items) {
          print('Timestamp: ${data.timestamp}, X: ${data.x}, Y: ${data.y}, Z: ${data.z}');
        }
      }
    });

    return allData;
    print(allData);
  } catch (e) {
    print('Error fetching data: $e');
    return {}; // Return empty map in case of error
  }
}
import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://zmartrest-pb.cloud.spetsen.net/');


  // Authenticate the user
  try {
    final authData = await pb.collection('users').authWithPassword('alwin.forslund@hitachigymnasiet.se', 'Jagälskarspetsen');
    final userData = authData.record;
    final userMap = userData.data;  

    print('User authenticated:');
    print('ID: ${userMap['id']}');
    print('Email: ${userMap['email']}');

    // Add accelerometer data
    await addAccelerometerData(pb, userMap['id'], 1633046400, 0.45, -0.23, 9.81);  // Example 1
    await addAccelerometerData(pb, userMap['id'], 1633046500, 0.50, -0.30, 9.82);  // Example 2

    //Add heartrate data
    

    // Fetch accelerometer data for the user
    await fetchAccelerometerData(pb, userMap['id']);

  } catch (e) {
    print('Error during authentication: $e');
  }

  // Fetch some records
  try {
    final result = await pb.collection('example').getList(
      page: 1,
      perPage: 10,
    );

    print('Fetched records:');
    for (var record in result.items) {
      print(record.toJson());
    }
  } catch (e) {
    print('Failed to fetch records: $e');
  }

  // Add a new record to a collection
  try {
    final newData = {
      "field1": "value1",
      "field2": "value2",
      "field3": 123,
    };

    final record = await pb.collection('example').create(body: newData);

    print('New record added successfully:');
    print(record.toJson());
  } catch (e) {
    print('Failed to add a new record: $e');
  }
}

// Add accelerometer data to PocketBase
Future<void> addAccelerometerData(PocketBase pb, String userId, int epoch, double x, double y, double z) async {
  try {
    final accelerometerData = {
      'epoch': epoch,
      'x': x,
      'y': y,
      'z': z,
      'user': userId  // Link to the authenticated user
    };

    final result = await pb.collection('accelerometer_data').create(body: accelerometerData);
    print('Accelerometer data added:');
    print(result.toJson());
  } catch (e) {
    print('Error adding accelerometer data: $e');
  }
}


Future<void> fetchAccelerometerData(PocketBase pb, String userId) async {
  try {
    final result = await pb.collection('accelerometer_data').getList(
      page: 1,         
      perPage: 10,     
      filter: 'user = "$userId"',  
    );

    print('Fetched accelerometer data for user:');
    for (var record in result.items) {
      print('Epoch: ${record.data['epoch']}, X: ${record.data['x']}, Y: ${record.data['y']}, Z: ${record.data['z']}');
    }
  } catch (e) {
    print('Failed to fetch accelerometer data: $e');
  }
}

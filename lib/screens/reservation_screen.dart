import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> with SingleTickerProviderStateMixin {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('parking_spots');
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Reservation'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset('assets/icons/back.png', fit: BoxFit.contain),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
        stream: databaseRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List parkingSpots = data.keys.toList();

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: parkingSpots.length,
              itemBuilder: (context, index) {
                String spotId = parkingSpots[index];
                Map<dynamic, dynamic> spotData = data[spotId];
                String status = spotData['status'];
                String displayText;

                if (status == 'available') {
                  displayText = 'Status: Available';
                } else if (status == 'occupied' &&
                    spotData.containsKey('carType') &&
                    spotData.containsKey('plateNumber')) {
                  displayText =
                  'Status: Occupied by ${spotData['carType']} (${spotData['plateNumber']})';
                } else {
                  displayText = 'Status: Occupied';
                }

                Widget trailingIcon;
                if (status == 'available') {
                  trailingIcon = ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      _showReservationDialog(context, spotId);
                    },
                    child: const Text('Reserve', style: TextStyle(color: Colors.white)),
                  );
                } else {
                  bool isCurrentUserReservation =
                      spotData['userEmail'] == currentUser?.email;
                  trailingIcon = Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      isCurrentUserReservation
                          ? 'assets/icons/yours.png'
                          : 'assets/icons/booked.png',
                      fit: BoxFit.contain,
                    ),
                  );
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10.0),
                    title: Text(
                      '$spotId',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(displayText),
                    trailing: trailingIcon,
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  void _showReservationDialog(BuildContext context, String spotId) {
    final TextEditingController carTypeController = TextEditingController();
    final TextEditingController plateNumberController = TextEditingController();
    final TextEditingController durationController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.local_parking, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Text('Reserve Spot $spotId'))
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: carTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Car Type',
                      prefixIcon: Icon(Icons.directions_car_filled),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: plateNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Plate Number',
                      prefixIcon: Icon(Icons.confirmation_number),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (hours)',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: () async {
                String carType = carTypeController.text;
                String plateNumber = plateNumberController.text;
                int duration = int.tryParse(durationController.text) ?? 0;

                if (carType.isNotEmpty && plateNumber.isNotEmpty && duration > 0) {
                  setState(() {
                    _isLoading = true;
                  });

                  DateTime startTime = DateTime.now();
                  DateTime endTime = startTime.add(Duration(hours: duration));

                  await databaseRef.child(spotId).update({
                    'status': 'occupied',
                    'carType': carType,
                    'plateNumber': plateNumber,
                    'userEmail': currentUser?.email,
                    'startTime': startTime.toIso8601String(),
                    'endTime': endTime.toIso8601String(),
                  }).then((_) {
                    setState(() {
                      _isLoading = false;
                    });

                    Navigator.of(context).pop();

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.green, size: 60),
                              const SizedBox(height: 20),
                              const Text(
                                'Reservation Successful!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  });
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

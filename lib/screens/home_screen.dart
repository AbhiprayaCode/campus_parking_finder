import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:campus_parking_finder/screens/reservation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('parking_spots');
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Parking Reservations'),
        actions: [
          customIconButton('assets/icons/logout.png', () {
            FirebaseAuth.instance.signOut();
          }),
        ],
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
        stream: databaseRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            Map<dynamic, dynamic> occupiedSpots = Map.fromEntries(
              data.entries.where((entry) =>
              entry.value['status'] == 'occupied' &&
                  entry.value['userEmail'] == currentUser?.email),
            );

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: data.keys.length,
              itemBuilder: (context, index) {
                String spotId = data.keys.elementAt(index);
                Map<dynamic, dynamic> spotData = data[spotId];
                String status = spotData['status'];

                // Tombol untuk melakukan reservasi jika status "available"
                Widget trailingWidget = status == 'available'
                    ? ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReservationScreen()),
                    );
                  },
                  child: const Text('Reserve'),
                )
                    : IconButton(
                  icon: Image.asset('assets/icons/exit.png'),
                  onPressed: () {
                    _showExitConfirmationDialog(context, spotId, spotData);
                  },
                );

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10.0),
                    title: Text(
                      '$spotId',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      status == 'occupied'
                          ? 'Car: ${spotData['carType']} (${spotData['plateNumber']})'
                          : 'Status: Available',
                    ),
                    trailing: trailingWidget,
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No reservations found.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReservationScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset('assets/icons/add.png', fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _showExitConfirmationDialog(BuildContext context, String spotId, Map spotData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Expanded(child: Text('Cancel Reservation?')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Car: ${spotData['carType']} (${spotData['plateNumber']})'),
              const SizedBox(height: 10),
              const Text('Are you sure you want to cancel this reservation?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                databaseRef.child(spotId).update({'status': 'available'}).then((_) {
                  Navigator.of(context).pop();
                  _showCancellationSuccessDialog(context);
                });
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showCancellationSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 20),
              Text(
                'Reservation Cancelled Successfully!',
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
  }
}

Widget customIconButton(String assetPath, VoidCallback onPressed) {
  return IconButton(
    icon: Image.asset(
      assetPath,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    ),
    onPressed: onPressed,
  );
}

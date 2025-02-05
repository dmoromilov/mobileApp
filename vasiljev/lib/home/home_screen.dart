import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vasiljev/calendar/appointment.dart';
import 'package:vasiljev/home/nav_bar.dart';

class HomeScreen extends StatelessWidget {
  // Fetch appointments from Firestore
  Stream<List<Appointment>> getAppointments() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  void _navigateToPage(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/book');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  // Cancel an appointment in Firestore
  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId) // Use the document ID to cancel the correct appointment
          .delete();
      // Optionally, show a success message or notification
      print('Appointment cancelled successfully');
    } catch (e) {
      print('Failed to cancel appointment: $e');
      // Optionally, show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/logo.png',
          height: 80, // Increased height for larger image
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 0),
            const SizedBox(height: 0),

            // Display appointments from Firebase
            StreamBuilder<List<Appointment>>(
              stream: getAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No appointments found.'));
                } else {
                  final appointments = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              'Appointment with ${appointment.stylistName}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    SizedBox(width: 5),
                                    Text(
                                      'Time: ${appointment.time}',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    SizedBox(width: 5),
                                    Text(
                                      'Date: ${appointment.date.toLocal().toString().split(' ')[0]}',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.cut, size: 16, color: Colors.grey), // Updated icon for Service
                                    SizedBox(width: 5),
                                    Text(
                                      ' ${appointment.serviceType}',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                // Confirm cancellation
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Cancel Appointment'),
                                    content: Text('Are you sure you want to cancel this appointment?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Cancel the appointment
                                          await _cancelAppointment(appointment.appointmentID); // Updated to appointmentID
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) => _navigateToPage(index, context),
      ),
    );
  }
}

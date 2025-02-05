// import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String appointmentID; // Changed to appointmentID
  final String userId;
  final String stylistName;
  final DateTime date;
  final String time;
  final String serviceType;
  final int duration;

  Appointment({
    required this.appointmentID, // Changed to appointmentID
    required this.userId,
    required this.stylistName,
    required this.date,
    required this.time,
    required this.serviceType,
    required this.duration,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'stylistName': stylistName,
      'date': date,
      'time': time,
      'serviceType': serviceType,
      'duration': duration,
    };
  }

  // Create object from Firestore document, passing the document ID
  factory Appointment.fromMap(Map<String, dynamic> map, String documentId) {
    return Appointment(
      appointmentID: documentId, // Assign the Firestore document ID to appointmentID
      userId: map['userId'] ?? '',
      stylistName: map['stylistName'] ?? '',
      date: map['date'].toDate(),
      time: map['time'] ?? '',
      serviceType: map['serviceType'] ?? '',
      duration: map['duration'] ?? 0,
    );
  }

  // Override the toString method to display the appointment information
  @override
  String toString() {
    return '$serviceType with $stylistName on ${date.toLocal().toString()} at $time, Duration: $duration minutes';
  }
}


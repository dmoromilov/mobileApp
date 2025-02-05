import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vasiljev/calendar/appointment.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dohvatanje termina za određenog stilistu
  Future<List<Appointment>> getAppointments(String stylistName) async {
    QuerySnapshot snapshot = await _firestore
        .collection('appointments')
        .where('stylistName', isEqualTo: stylistName)
        .get();

    return snapshot.docs
        .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id)) // Dodaj documentId
        .toList(); // Vraća List<Appointment>
  }

  // Provera da li termin već postoji
  Future<bool> checkAppointmentExists(DateTime date, String time, String stylistName) async {
    QuerySnapshot snapshot = await _firestore
        .collection('appointments')
        .where('stylistName', isEqualTo: stylistName)
        .where('date', isEqualTo: date)
        .where('time', isEqualTo: time)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Dodavanje novog termina
  Future<void> bookAppointment(Appointment appointment) async {
    await _firestore.collection('appointments').add(appointment.toMap());
  }
}


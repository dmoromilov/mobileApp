import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vasiljev/calendar/stylist_calendar_screen.dart'; // Dodajte ovu liniju

class StylistSelectionScreen extends StatelessWidget {
  final String salonType;
  final List<String> stylists;

  const StylistSelectionScreen({
    Key? key,
    required this.salonType,
    required this.stylists,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$salonType',
          style: TextStyle(color: Colors.black), // Set title text color to black
        ),
        backgroundColor: Colors.white, // Set app bar background color to white
      ),
      body: Container(
        color: Colors.white, // Set background color of the body to white
        child: ListView.builder(
          itemCount: stylists.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                stylists[index],
                style: TextStyle(fontSize: 18, color: Colors.black), // Set text color to black
              ),
              onTap: () async {
                // Dohvatanje trenutnog korisnika
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // Ako je korisnik prijavljen, prosledite userId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StylistCalendarScreen(
                        stylistName: stylists[index],
                        userId: user.uid, // Koristite user.uid
                      ),
                    ),
                  );
                } else {
                  // Ako korisnik nije prijavljen, možete prikazati obaveštenje ili preusmeriti na ekran za prijavu
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You must be logged in to book an appointment.')),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

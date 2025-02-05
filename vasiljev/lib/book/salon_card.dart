import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

//Import screen
import 'package:vasiljev/book/stylist_selection_screen.dart';


class SalonCard extends StatelessWidget {
  final String salonType;
  final String address;
  final String phone;
  final List<String> stylists;

  const SalonCard({
    Key? key,
    required this.salonType,
    required this.address,
    required this.phone,
    required this.stylists,
  }) : super(key: key);

  Future<void> _launchPhone(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adding empty space above salonType text
          SizedBox(height: 60), // Adjust the height to increase space above salonType
          // salonType text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                salonType,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),  // Space below salonType text
          // Address text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              address,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 10),  // Space below address text
          // Phone number with clickable link
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () => _launchPhone(phone),
              child: Text(
                phone,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          // Adding space between phone number and "Select Stylist" button
          SizedBox(height: 0), // You can adjust this height if needed
          // "Select Stylist" button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StylistSelectionScreen(
                        salonType: salonType,
                        stylists: stylists,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  'Select Stylist',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

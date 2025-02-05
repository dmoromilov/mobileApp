import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Import screen
import 'package:vasiljev/book/salon_card.dart';
import 'package:vasiljev/home/nav_bar.dart';

class BookScreen extends StatefulWidget {
  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final PageController _pageController = PageController();
  late LatLng _selectedSalonLocation;
  GoogleMapController? _mapController;
  int _currentIndex = 1; // Set initial index to "Book" tab

  @override
  void initState() {
    super.initState();
    _selectedSalonLocation = LatLng(45.38824746433581, 20.39119153441756); // Initial location
  }

  void _changeSalonLocation(int index) {
    setState(() {
      _selectedSalonLocation = (index == 0)
          ? LatLng(45.38824746433581, 20.39119153441756) // Men's salon
          : LatLng(45.37971753316127, 20.39118389975213); // Women's salon
    });

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_selectedSalonLocation),
      );
    }
  }

  void _onNavBarTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      // Navigate to corresponding screens
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          break; // Already on "Book" screen
        case 2:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    }
  }

  @override
  void dispose() {
    if (_mapController != null) {
      _mapController!.dispose(); // Release map resources
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color for the entire Scaffold
      body: Column(
        children: [
          // Salon cards with a fixed height
          Container(
            height: MediaQuery.of(context).size.height * 0.3, // Adjusted height for salon cards
            child: PageView(
              controller: _pageController,
              onPageChanged: _changeSalonLocation,
              children: [
                SalonCard(
                  salonType: 'Vasiljev frizerski atelje',
                  address: 'Cara Dušana 81',
                  phone: '023 568 688',
                  stylists: ['Bojan', 'Ivan'],
                ),
                SalonCard(
                  salonType: 'Vasiljev frizerski atelje2',
                  address: 'Trg slobode 3',
                  phone: '069 666 023',
                  stylists: ['Jelena', 'Ana'],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          SmoothPageIndicator(
            controller: _pageController,
            count: 2, // Number of pages
            effect: WormEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: Colors.black,
              dotColor: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          // Google Map takes the remaining space
          Expanded(
            child: Container(
              width: double.infinity, // Make sure the map takes up full width
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  if (_mapController != controller) {
                    _mapController = controller;
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: _selectedSalonLocation,
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('salonLocation'),
                    position: _selectedSalonLocation,
                    infoWindow: InfoWindow(title: 'Salon Location'),
                  ),
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}

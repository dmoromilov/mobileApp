import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For time formatting
import 'package:table_calendar/table_calendar.dart';
import 'package:vasiljev/calendar/appointment.dart'; // Import the Appointment model
import 'package:vasiljev/calendar/appointment_service.dart'; // Import the AppointmentService

class StylistCalendarScreen extends StatefulWidget {
  final String stylistName;
  final String userId;

  const StylistCalendarScreen({
    Key? key,
    required this.stylistName,
    required this.userId,
  }) : super(key: key);

  @override
  _StylistCalendarScreenState createState() => _StylistCalendarScreenState();
}

class _StylistCalendarScreenState extends State<StylistCalendarScreen> {
  Map<DateTime, List<Appointment>> _appointments = {}; // List of appointments by date
  late DateTime _focusedDay; // Focused day for TableCalendar
  final AppointmentService _appointmentService = AppointmentService();
  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _loadAppointments();
  }
  // Load appointments from Firestore
  Future<void> _loadAppointments() async {
    List<Appointment> appointments = await _appointmentService.getAppointments(widget.stylistName);
    final Map<DateTime, List<Appointment>> appointmentsMap = {};
    for (var appointment in appointments) {
      final appointmentDate = appointment.date;
      // Initialize the list if not already present
      if (!appointmentsMap.containsKey(appointmentDate)) {
        appointmentsMap[appointmentDate] = [];
      }
      // Add appointment to the map
      appointmentsMap[appointmentDate]!.add(appointment);
    }
    setState(() {
      _appointments = appointmentsMap;
    });
    print('Appointments: $_appointments'); // Log to check loaded appointments
  }
  // Convert occupied dates to a list
  List<DateTime> _getOccupiedDates() {
    return _appointments.keys.toList();
  }
  // Get color for each date
  Color _getDateColor(DateTime date) {
    if (isWeekend(date)) {
      return Colors.transparent;
    }
    if (date.isBefore(DateTime.now()) && isWeekday(date)) {
      return Colors.grey; // Past dates marked gray
    }
    if (_appointments.containsKey(normalizeDate(date))) {
      if (_appointments[normalizeDate(date)]!.length >= 7) {
        return Colors.red; // Fully booked date
      }
    }
    return Colors.green; // Available date
  }
  bool isWeekend(DateTime date) {
    return date.weekday == DateTime.sunday || date.weekday == DateTime.monday;
  }
  bool isWeekday(DateTime date) {
    return date.weekday >= DateTime.tuesday && date.weekday <= DateTime.saturday;
  }
  Future<void> _showTimeSlotPicker(DateTime selectedDay, String service, int duration) async {
    List<String> bookedSlots = [];
    // Fetch appointments for the selected day and stylist
    List<Appointment> appointments = await _appointmentService.getAppointments(widget.stylistName);
    // Filter appointments for the selected day
    var dayAppointments = appointments.where((appointment) =>
    appointment.date.year == selectedDay.year &&
        appointment.date.month == selectedDay.month &&
        appointment.date.day == selectedDay.day
    ).toList();
    // Populate bookedSlots with already booked times
    for (var appointment in dayAppointments) {
      bookedSlots.add(appointment.time);
    }
    // Define available time slots (assuming times from 10:00 to 19:00, with 1-hour intervals)
    List<String> availableSlots = [];
    for (int i = 10; i < 20; i++) {
      String slot = '${i.toString().padLeft(2, '0')}:00';

      if (!bookedSlots.contains(slot)) availableSlots.add(slot);
    }
    // Show the time picker dialog with available slots
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Select Time for $service'),
        content: Container(
          height: 400,
          width: double.maxFinite,
          child: ListView(
            children: availableSlots.map((slot) {
              return ListTile(
                title: Text(
                  slot,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  DateTime selectedTime = DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                    int.parse(slot.split(":")[0]),
                    int.parse(slot.split(":")[1]),
                  );
                  _bookAppointment(selectedTime, service, duration);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  // Book the selected appointment
  Future<void> _bookAppointment(DateTime selectedTime, String service, int duration) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String formattedTime = DateFormat('HH:mm').format(selectedTime);
      // Check if the time slot already exists
      bool exists = await _appointmentService.checkAppointmentExists(selectedTime, formattedTime, widget.stylistName);
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This time slot is already booked. Please choose another one.')),
        );
        return;
      }
      // Create appointment object
      Appointment appointment = Appointment(
        userId: user.uid,
        stylistName: widget.stylistName,
        date: selectedTime,
        time: formattedTime,
        serviceType: service,
        duration: duration,
        appointmentID: '', // ID will be generated automatically by Firestore
      );
      // Add appointment to Firestore
      await _appointmentService.bookAppointment(appointment);
      await _loadAppointments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment successfully booked.')),
      );
      // Return to Home screen
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointment for ${widget.stylistName}',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2024),
              lastDay: DateTime(2055),
              selectedDayPredicate: (day) {
                return _appointments.keys.contains(day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (selectedDay.isBefore(DateTime.now().toLocal().copyWith(hour: 0, minute: 0))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cannot book past dates')),
                  );
                  return;
                }
                if (isWeekend(selectedDay)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cannot book appointments on Sundays or Mondays')),
                  );
                  return;
                }
                setState(() {
                  _focusedDay = focusedDay;
                });
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(
                      'Select Service Type',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('Haircut (40 mins)', style: TextStyle(fontSize: 16)),
                          onTap: () {
                            Navigator.pop(context);
                            _showTimeSlotPicker(selectedDay, 'Haircut', 40);
                          },
                        ),
                        ListTile(
                          title: Text('Beard Trim (30 mins)', style: TextStyle(fontSize: 16)),
                          onTap: () {
                            Navigator.pop(context);
                            _showTimeSlotPicker(selectedDay, 'Beard Trim', 30);
                          },
                        ),
                        ListTile(
                          title: Text('Haircut & Beard Trim (70 mins)', style: TextStyle(fontSize: 16)),
                          onTap: () {
                            Navigator.pop(context);
                            _showTimeSlotPicker(selectedDay, 'Haircut & Beard Trim', 70);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, events) {
                  if (isWeekend(date)) {
                    return Container(
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  Color dateColor = _getDateColor(date);
                  return Container(
                    decoration: BoxDecoration(
                      color: dateColor == Colors.green
                          ? Colors.green.withOpacity(0.3)
                          : (dateColor == Colors.red
                          ? Colors.red.withOpacity(0.3)
                          : Colors.transparent),
                      border: dateColor == Colors.green
                          ? Border.all(color: Colors.green.shade900)
                          : (dateColor == Colors.red
                          ? Border.all(color: Colors.red.shade900)
                          : Border()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              eventLoader: (day) {
                return _appointments[day] ?? [];
              },
              availableGestures: AvailableGestures.none,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

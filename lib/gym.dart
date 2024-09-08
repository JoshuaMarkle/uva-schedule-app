import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // For decoding the gym data

class GymPage extends StatefulWidget {
  const GymPage({super.key});

  @override
  _GymPageState createState() => _GymPageState();
}

class _GymPageState extends State<GymPage> {
  Future<List<Map<String, String>>>? gymData;

  @override
  void initState() {
    super.initState();
    gymData = fetchGymData(); // Fetch gym data when the app starts
  }

  // Sample gym data (same structure as the previous JSON provided)
  final String gymJsonData = '''
  {
    "gyms": [
      {
        "name": "AFC",
        "times": [
          "6:00am – 11:59pm",
          "6:00am – 11:59pm",
          "6:00am – 11:59pm",
          "6:00am – 11:59pm",
          "6:00am – 11:59pm",
          "9:00am – 11:59pm",
          "9:00am – 11:59pm"
        ]
      },
      {
        "name": "Slaughter Gym",
        "times": [
          "11:00am – 11:00pm",
          "11:00am – 11:00pm",
          "11:00am – 11:00pm",
          "11:00am – 11:00pm",
          "11:00am – 10:00pm",
          "12:00pm – 10:00pm",
          "12:00pm – 11:00pm"
        ]
      }
    ]
  }
  ''';

  // Function to load the gym data
  Future<List<Map<String, String>>> fetchGymData() async {
    Map<String, dynamic> gymDataParsed = jsonDecode(gymJsonData);
    List gyms = gymDataParsed['gyms'];
    List<Map<String, String>> gymList = [];
    DateTime currentTime = DateTime.now();

    for (var gym in gyms) {
      List<String> times = List<String>.from(gym['times']);
      String todayTimeRange = times[currentTime.weekday - 1]; // Get today's time range

      String status = isGymOpen(todayTimeRange, currentTime) ? 'Open' : 'Closed';
      gymList.add({
        'gym': gym['name'],
        'status': status,
      });
    }

    return gymList;
  }

  // Function to check if the gym is open based on its time range
  bool isGymOpen(String timeRange, DateTime currentTime) {
    if (timeRange == "Closed") return false;
    List<String> times = timeRange.split(' – '); // Use '–' dash

    DateFormat dateFormat = DateFormat("h:mma");
    DateTime openingTime = dateFormat.parse(times[0].trim().toUpperCase());
    DateTime closingTime = dateFormat.parse(times[1].trim().toUpperCase());

    // Adjust the parsed times to match the current date
    openingTime = DateTime(currentTime.year, currentTime.month, currentTime.day,
        openingTime.hour, openingTime.minute);
    closingTime = DateTime(currentTime.year, currentTime.month, currentTime.day,
        closingTime.hour, closingTime.minute);

    return currentTime.isAfter(openingTime) && currentTime.isBefore(closingTime);
  }

  // Widget to create a card for each gym
  Widget buildGymCard(String gym, String status) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 4, // Blur radius
            offset: Offset(0, 2), // Changes shadow position
          ),
        ],
      ),
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gym,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              status,
              style: TextStyle(
                fontSize: 16,
                color: status.toLowerCase() == 'open' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gym Times')),
      body: FutureBuilder<List<Map<String, String>>>(
        future: gymData, // The future that holds the gym data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while waiting for data
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if there was an error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show message if no data is available
            return Center(child: Text('No gym data available'));
          } else {
            // Show the list of gyms in a ListView
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var gym = snapshot.data![index];
                return buildGymCard(gym['gym']!, gym['status']!); // Generate a card for each gym
              },
            );
          }
        },
      ),
    );
  }
}
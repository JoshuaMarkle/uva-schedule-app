import 'package:flutter/material.dart';
import 'package:puppeteer/puppeteer.dart' as puppeteer;
import 'package:intl/intl.dart';
import 'cards.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  Future<List<Map<String, String>>>? libraryData;

  @override
  void initState() {
    super.initState();
    libraryData = fetchLibraryData(); // Fetch library data when the app starts
  }

  // Function to scrape data using Puppeteer
  Future<List<Map<String, String>>> fetchLibraryData() async {
    var browser = await puppeteer.puppeteer.launch(headless: true); // Launch a headless browser
    var page = await browser.newPage();

    // Navigate to the UVA libraries hours page
    await page.goto('https://cal.lib.virginia.edu/hours/');

    // Wait for the table of hours to load
    await page.waitForSelector('table.s-lc-h-w');

    // Get the current day of the week (0 for Sunday, 6 for Saturday)
    int currentDayIndex = (DateTime.now().weekday) % 7; // Adjusted to 0-based for Sunday

    // Scrape the library times and names
    var libraryTimes = await page.evaluate('''() => {
      const currentDayIndex = new Date().getDay(); // Get the current day
      const rows = Array.from(document.querySelectorAll('table.s-lc-h-w tbody tr'));
      return rows.map(row => {
        const libraryName = row.querySelector('td.s-lc-h-locname')?.innerText?.trim();
        const hoursForToday = row.querySelectorAll('td')[currentDayIndex + 1]?.innerText?.trim();
        return libraryName && hoursForToday ? { library: libraryName, hours: hoursForToday } : null;
      })
      .filter(item => item !== null)
      .slice(0, 8);
    }''');

    await browser.close(); // Close the browser

    List<Map<String, String>> libraryList = [];
    DateTime currentTime = DateTime.now();

    // Parse and check if the library is open or closed
    for (var library in libraryTimes) {
      String status = isLibraryOpen(library['hours'], currentTime) ? 'Open' : 'Closed';
      libraryList.add({
        'library': library['library'],
        'status': status,
        'hours': library['hours']
      });
    }

    return libraryList;
  }

  bool isLibraryOpen(String timeRange, DateTime currentTime) {
    if (timeRange == "Closed") return false;
    List<String> times = timeRange.split(' – '); // Note: Use '–' (dash)

    DateFormat dateFormat = DateFormat("ha");
    DateTime openingTime = dateFormat.parse(times[0].trim().toUpperCase());
    DateTime closingTime = dateFormat.parse(times[1].trim().toUpperCase());
    return currentTime.isAfter(openingTime) && currentTime.isBefore(closingTime);
  }

  // Widget to create a card for each library
  Widget buildLibraryCard(String library, String status) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Color of shadow
            spreadRadius: 2, // Spread radius
            blurRadius: 4, // Blur radius
            offset: Offset(0, 2), // Changes position of shadow
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
              library,
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
      appBar: AppBar(title: Text('Library Times')),
      body: FutureBuilder<List<Map<String, String>>>(
        future: libraryData, // The future that holds the data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while waiting for data
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if there was an error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show message if no data is available
            return Center(child: Text('No library data available'));
          } else {
            // Show the list of libraries in a ListView
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var library = snapshot.data![index];
                return buildCard(library['library']!, library['status']!, library['hours']!);
              },
            );
          }
        },
      ),
    );
  }
}

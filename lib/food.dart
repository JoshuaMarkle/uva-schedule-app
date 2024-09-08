import 'package:flutter/material.dart';
import 'package:puppeteer/puppeteer.dart' as puppeteer;

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  // Future to hold the scraped data
  Future<List<Map<String, String>>>? diningData;

  @override
  void initState() {
    super.initState();
    diningData = fetchDiningData(); // Fetch dining data when the app starts
  }

  // Function to scrape data using Puppeteer
  Future<List<Map<String, String>>> fetchDiningData() async {
    var browser = await puppeteer.puppeteer.launch(headless: true); // Launch a headless browser
    var page = await browser.newPage();

    // Navigate to the UVA dining page
    await page.goto('https://virginia.campusdish.com/en/LocationsAndMenus');

    // Wait for the list of locations to load
    await page.waitForSelector('#listLocations');

    // Scrape the data
    var diningHalls = await page.evaluate('''() => {
      const locations = Array.from(document.querySelectorAll('#listLocations li')).map(location => {
          const locationName = location.querySelector('.location-card-header__display-name')?.textContent?.trim();
          const status = location.querySelector('.location-card-status > div > span')?.textContent?.trim();
          if (locationName && status) {
              return {
                  'location': locationName,
                  'status': status
              };
          }
      }).filter(item => item !== undefined); // Filter out any undefined entries
      return locations;
    }''');

    await browser.close(); // Close the browser

    // Convert dynamic result into a typed list of maps
    List<Map<String, String>> diningHallsList = [];
    for (var hall in diningHalls) {
      diningHallsList.add({
        'location': hall['location'],
        'status': hall['status'],
      });
    }

    return diningHallsList;
  }

  // Widget to create a card for each dining hall
  Widget buildDiningCard(String location, String status) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow:[
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), //color of shadow
            spreadRadius: 2, //spread radius
            blurRadius: 4, // blur radius
            offset: Offset(0, 2), // changes position of shadow
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
              location,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '$status',
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
      appBar: AppBar(title: Text('Food Times')),
      body: FutureBuilder<List<Map<String, String>>>(
        future: diningData, // The future that holds the data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while waiting for data
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if there was an error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show message if no data is available
            return Center(child: Text('No dining data available'));
          } else {
            // Show the list of dining halls in a ListView
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var diningHall = snapshot.data![index];
                return buildDiningCard(diningHall['location']!, diningHall['status']!); // Generate a card for each dining hall
              },
            );
          }
        },
      ),
    );
  }
}

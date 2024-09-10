import 'package:flutter/material.dart';

// Widget to create a card for each dining hall
Widget buildCard(String location, String status, String timeFrame) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$status',
                style: TextStyle(
                  fontSize: 16,
                  color: status.toLowerCase() == 'open' ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '$timeFrame',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


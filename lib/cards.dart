import 'package:flutter/material.dart';

// A reusable card widget that displays the name and status
class ReusableCardList extends StatelessWidget {
  final List<Map<String, String>> items;

  ReusableCardList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8),
          elevation: 3,
          child: ListTile(
            title: Text(items[index]['name'] ?? 'Unknown Name'),
            subtitle: Text(items[index]['status'] ?? 'Unknown Status'),
            trailing: Icon(Icons.arrow_forward),
          ),
        );
      },
    );
  }
}

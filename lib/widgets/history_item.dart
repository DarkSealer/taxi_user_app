import 'package:flutter/material.dart';
import 'package:taxi_driver_app/assistants/assistant_methods.dart';
import 'package:taxi_driver_app/models/history.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({super.key, required this.history});
  final History history;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                Image.asset(
                  'images/pickicon.png',
                  height: 16,
                  width: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    history.pickUp,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '\$${history.fares}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF171717),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Image.asset(
                  'images/desticon.png',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    history.dropOff,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AssistantMethods.formatTripDate(history.createdAt),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

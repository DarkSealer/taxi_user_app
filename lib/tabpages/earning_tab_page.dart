import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_driver_app/datahandler/appdata.dart';
import 'package:taxi_driver_app/screens/history_screen.dart';

class EarningTabPage extends StatelessWidget {
  EarningTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.black87,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: Column(
              children: [
                const Text(
                  'Total Earnings',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  '\$${Provider.of<AppData>(context, listen: false).earnings}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontFamily: 'Brand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        FlatButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            print('go to history page');
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 18,
            ),
            child: Row(
              children: [
                Image.asset(
                  'images/uberx.png',
                  width: 70,
                ),
                const SizedBox(
                  width: 16,
                ),
                const Text(
                  'Total Trips',
                  style: TextStyle(fontSize: 16),
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      Provider.of<AppData>(context, listen: false)
                          .tripCounter
                          .toString(),
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 2.0,
          thickness: 2,
        ),
      ],
    );
  }
}

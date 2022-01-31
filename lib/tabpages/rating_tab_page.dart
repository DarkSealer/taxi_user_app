import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '/configmaps.dart';

class RatingTabPage extends StatefulWidget {
  const RatingTabPage({Key? key}) : super(key: key);

  @override
  State<RatingTabPage> createState() => _RatingTabPageState();
}

class _RatingTabPageState extends State<RatingTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          margin: const EdgeInsets.all(5),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 22,
              ),
              const Text(
                'Your Ratings',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Brand',
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(
                height: 22,
              ),
              const Divider(
                height: 2,
                thickness: 2,
              ),
              const SizedBox(
                height: 16,
              ),
              RatingBar.builder(
                ignoreGestures: true, // dezactiveaza selectarea de rating
                initialRating: starCounter,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 45,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {},
              ),
              const SizedBox(
                height: 14,
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 65,
                  fontFamily: 'Signatra',
                  color: Colors.green,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

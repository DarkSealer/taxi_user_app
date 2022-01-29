import 'package:firebase_database/firebase_database.dart';

class Drivers {
  late String name;
  late String phone;
  late String email;
  late String id;
  late String car_color;
  late String car_model;
  late String car_number;

  Drivers({
    required this.name,
    required this.email,
    required this.phone,
    required this.id,
    required this.car_color,
    required this.car_model,
    required this.car_number,
  });

  Drivers.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key!;
    var values = dataSnapshot.value as Map<dynamic, dynamic>;
    phone = values["phone"];
    email = values["email"];
    name = values["name"];
    car_model = values["car_details"]["car_model"];
    car_color = values["car_details"]["car_color"];
    car_number = values["car_details"]["car_number"];
  }
}

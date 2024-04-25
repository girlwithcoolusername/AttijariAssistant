import 'package:flutter/material.dart';

class DialogUtils {
  final String image, title, description;
  final int price, size, id;
  final Color color;

  DialogUtils(
      {required this.image,
        required this.title,
        required this.description,
        required this.price,
        required this.size,
        required this.id,
        required this.color});
}

List<DialogUtils> products = [
  DialogUtils(
      id: 1,
      title: "Office Code",
      price: 234,
      size: 12,
      description: dummyText,
      image: "assets/images/attijariwafa-bank-logo.webp",
      color: Colors.black)
];

String dummyText =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since. When an unknown printer took a galley.";
import 'package:flutter/material.dart';

enum CarColors{
  black,
  grey,
  silver,
  white,
  blue,
  navy,
  petrol,
  whine,
  red,
  yellow,
  orange,
  green,
  pink,
}

Color getColor(CarColors color) {
  switch (color) {
    case CarColors.black: return Colors.black;
    case CarColors.grey: return Color.fromRGBO(47, 87, 85, 1);
    case CarColors.silver: return Colors.grey[400]!;
    case CarColors.white: return Colors.white;
    case CarColors.blue: return Colors.blue;
    case CarColors.navy: return Colors.blue[900]!;
    case CarColors.petrol: return Colors.teal;
    case CarColors.whine: return Color.fromRGBO(136, 8, 8, 1);
    case CarColors.red: return Colors.red;
    case CarColors.yellow: return Colors.yellow;
    case CarColors.orange: return Colors.orange;
    case CarColors.green: return Colors.green;
    case CarColors.pink: return Colors.pink;
  }
}

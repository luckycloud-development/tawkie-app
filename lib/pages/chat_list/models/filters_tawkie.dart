// Classe représentant un filtre
import 'package:flutter/material.dart';

class FilterTawkie {
  final IconData icon;
  final String title;
  final List<String> rooms;

  FilterTawkie({
    required this.icon,
    required this.title,
    required this.rooms,
  });
}

final List<FilterTawkie> filtersTawkie = [
  FilterTawkie(
    icon: Icons.person,
    title: 'All In One',
    rooms: [],
  ),
  FilterTawkie(
    icon: Icons.work,
    title: 'Works',
    rooms: [],
  ),
  FilterTawkie(
    icon: Icons.face,
    title: 'Friends',
    rooms: [],
  ),
];

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:sign_in_google_with_agora/modules/controllers/home_controller.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final HomeController controller;
  final SnakeBarBehaviour behaviour;
  final SnakeShape snakeShape;
  final ShapeBorder? shape;
  final EdgeInsets padding;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showSelectedLabels;
  final bool showUnselectedLabels;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;

  const AppBottomNavigationBar({
    super.key,
    required this.controller,
    this.behaviour = SnakeBarBehaviour.floating,
    this.snakeShape = SnakeShape.circle,
    this.shape,
    this.padding = const EdgeInsets.all(12),
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.blueGrey,
    this.showSelectedLabels = false,
    this.showUnselectedLabels = false,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SnakeNavigationBar.color(
        behaviour: behaviour,
        snakeShape: snakeShape,
        shape: shape,
        padding: padding,
        snakeViewColor: selectedColor,
        selectedItemColor: snakeShape == SnakeShape.indicator ? selectedColor : null,
        unselectedItemColor: unselectedColor,
        showUnselectedLabels: showUnselectedLabels,
        showSelectedLabels: showSelectedLabels,
        currentIndex: controller.selectedItemPosition.value,
        onTap: (index) => controller.selectedItemPosition.value = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'map'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
        ],
        selectedLabelStyle: selectedLabelStyle,
        unselectedLabelStyle: unselectedLabelStyle,
      ),
    );
  }
}

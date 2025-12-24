import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_google_with_agora/auth/firebase_auth/firebase_auth.dart';
import 'package:sign_in_google_with_agora/modules/controllers/home_controller.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_google_with_agora/modules/widgets/app_bottom_navigation.dart';

class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key});

  final ShapeBorder? bottomBarShape = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25)));
  final SnakeBarBehaviour snakeBarStyle = SnakeBarBehaviour.floating;
  final EdgeInsets padding = const EdgeInsets.all(12);

  final SnakeShape snakeShape = SnakeShape.circle;

  final bool showSelectedLabels = true;
  final bool showUnselectedLabels = true;

  final Color selectedColor = Colors.black;
  final Color unselectedColor = Colors.blueGrey;

  final Gradient selectedGradient = const LinearGradient(colors: [Colors.red, Colors.amber]);
  final Gradient unselectedGradient = const LinearGradient(colors: [Colors.red, Colors.blueGrey]);

  static const List<Color> containerColors = [Color(0xFFFDE1D7), Color(0xFFE4EDF5), Color(0xFFE7EEED), Color(0xFFF4E4CE)];
  final Color? containerColor = containerColors[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      extendBody: true,
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Home Screen'),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                try {
                  await AuthService.instance.signOutWithGoogle();

                  if (!context.mounted) return;
                  context.go('/login');
                } catch (e) {
                  // ignore: avoid_print
                  print('Logout error: $e');
                }
              },
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: AnimatedContainer(
        color: containerColor ?? containerColors[0],
        duration: const Duration(milliseconds: 400),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  FlutterLogo(size: 200),
                  SizedBox(height: 24),
                  Text('This is our beloved SnakeBar.', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 8),
                  Text('Swipe right to see different styles', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        controller: controller,
        behaviour: snakeBarStyle,
        snakeShape: snakeShape,
        shape: bottomBarShape,
        padding: padding,
        selectedColor: selectedColor,
        unselectedColor: unselectedColor,
        showSelectedLabels: showSelectedLabels,
        showUnselectedLabels: showUnselectedLabels,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
      ),
    );
  }
}

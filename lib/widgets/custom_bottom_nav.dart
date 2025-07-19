
import 'package:flutter/material.dart';


class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
    );
  }
}

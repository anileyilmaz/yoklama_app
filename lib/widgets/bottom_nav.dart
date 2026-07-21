import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    this.destinations = _studentDestinations,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<NavigationDestination> destinations;

  static const _studentDestinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Ana Sayfa',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_rounded),
      selectedIcon: Icon(Icons.history_rounded),
      label: 'Geçmiş',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book_rounded),
      label: 'Derslerim',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onChanged,
      backgroundColor: AppColors.cardOf(context),
      indicatorColor: AppColors.primarySoftOf(context),
      height: 70,
      destinations: destinations,
    );
  }
}

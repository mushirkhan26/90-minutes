import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/alert_utils.dart';
import '../theme/app_colors.dart';
import 'app_routes.dart';

class NavigationHost extends StatefulWidget {
  final Widget child;
  const NavigationHost({super.key, required this.child});

  @override
  State<NavigationHost> createState() => _NavigationHostState();
}

class _NavigationHostState extends State<NavigationHost> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedIndex = _getSelectedIndex(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (_selectedIndex != 0) {
            setState(() => _selectedIndex = 0);
            context.go(_routes[0]);
          } else {
            final now = DateTime.now();
            if (_lastBackPressed == null ||
                now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
              _lastBackPressed = now;
              AlertHelper.snackBarInfo(context, "Back again to exit");
            } else {
              SystemNavigator.pop();
            }
          }
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.primary,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                );
              }
              return const TextStyle(color: AppColors.grey808080);
            }),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: NavigationBar(
                height: 65,
                backgroundColor: AppColors.primary2.withValues(alpha: 0.2),
                indicatorColor: AppColors.primary,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  if (index != _selectedIndex) {
                    setState(() => _selectedIndex = index);
                    context.go(_routes[index]);
                  }
                },
                destinations: List.generate(_routes.length, (index) {
                  final isSelected = index == _selectedIndex;
                  return NavigationDestination(
                    icon: Icon(_icons[index], color: isSelected ? Colors.white : Colors.grey),
                    label: _labels[index],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _routes.indexWhere((r) => location.startsWith(r));
    return index == -1 ? 0 : index;
  }

  static const _routes = [
    AppRoutes.homeRoute,
    '/search',
    '/cart',
    AppRoutes.userProfile,
  ];

  static const _icons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.shopping_bag_rounded,
    Icons.person_rounded,
  ];

  static const _labels = [
    'Home',
    'Search',
    'Bag',
    'Profile',
  ];
}

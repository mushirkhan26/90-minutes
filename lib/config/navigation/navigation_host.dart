import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/core/utils/utils.dart';

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
              // Exit the app
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
                ); // selected label color
              }
              return const TextStyle(color: AppColors.grey808080); // unselected label color
            }),
          ),
          child: Container(
            decoration: BoxDecoration(
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
                    icon: AnimatedScale(
                      scale: 1.0, // isSelected ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Icon(_icons[index], color: isSelected ? Colors.white : Colors.grey),
                    ),
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
    return _routes.indexWhere((r) => location.startsWith(r));
  }

  static const _routes = [
    AppRoutes.homeRoute,
    AppRoutes.chatRoute,
    AppRoutes.meetRoute,
    AppRoutes.mailRoute,
  ];

  static const _icons = [
    Icons.home_rounded,
    Icons.chat_bubble_rounded,
    Icons.video_call_rounded,
    Icons.mail_rounded,
  ];

  static const _labels = ['Home', 'Chat', 'Meet', 'Mail'];
}

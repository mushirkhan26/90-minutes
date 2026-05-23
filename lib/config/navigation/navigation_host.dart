import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_90/core/utils/alert_utils.dart';
import 'package:delivery_90/features/cart/bloc/cart_bloc.dart';
import 'package:delivery_90/features/cart/bloc/cart_state.dart';
import 'package:delivery_90/config/theme/app_colors.dart';
import 'package:delivery_90/config/navigation/app_routes.dart';

import '../../features/wishlist/bloc/wishlist_bloc.dart';
import '../../features/wishlist/bloc/wishlist_state.dart';

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
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newIndex = _getSelectedIndex(context);
    if (newIndex != _selectedIndex) {
      setState(() => _selectedIndex = newIndex);
    }
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
            if (_canExit()) {
              SystemNavigator.pop();
            } else {
              if (!mounted) return;
              AlertHelper.snackBarInfo(context, "Back again to exit");
            }
          }
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                if (index != _selectedIndex) {
                  setState(() => _selectedIndex = index);
                  _navigateTo(index);
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primaryDarkGreen,
              unselectedItemColor: AppColors.grey808080,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: _CartIconWithBadge(),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 2 ? Icons.receipt_long_rounded : Icons.receipt_long_outlined),
                  label: 'Orders',
                ),
                const BottomNavigationBarItem(
                  icon: _WishlistIconWithBadge(),
                  label: 'Wishlist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 4 ? Icons.person_rounded : Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canExit() {
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      return false;
    }
    return true;
  }

  int _getSelectedIndex(BuildContext context) {
    try {
      // GoRouterState.of(context) ka sahi upyog
      final location = GoRouterState.of(context).uri.toString();
      final index = _routes.indexWhere((r) => location.startsWith(r));
      return index == -1 ? 0 : index;
    } catch (e) {
      return 0; // Fallback agar state na mile
    }
  }
  // int _getSelectedIndex(BuildContext context) {
  //   final location = GoRouterState.of(context).uri.toString();
  //   final index = _routes.indexWhere((r) => location.startsWith(r));
  //   return index == -1 ? 0 : index;
  // }

  static const _routes = [
    AppRoutes.homeRoute,
    AppRoutes.cartRoute,
    AppRoutes.ordersRoute,
    AppRoutes.wishlistRoute,
    AppRoutes.userProfile,
  ];

  void _navigateTo(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.homeRoute);
        break;
      case 1:
        context.go(AppRoutes.cartRoute);
        break;
      case 2:
        context.go(AppRoutes.ordersRoute);
        break;
      case 3:
        context.go(AppRoutes.wishlistRoute);
        break;
      case 4:
        context.go(AppRoutes.userProfile);
        break;
    }
  }
}

// class _CartIconWithBadge extends StatelessWidget {
//   const _CartIconWithBadge();
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<CartBloc, CartState>(
//       builder: (context, state) {
//         final count = state is CartLoaded ? state.cart.items.length : 0;
//         return Badge(
//           label: count > 99 ? const Text('99+') : Text(count.toString()),
//           backgroundColor: AppColors.primaryAmber,
//           isLabelVisible: count > 0,
//           child: Icon(context.watch<GoRouterState>().uri.toString().startsWith(AppRoutes.cartRoute) ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined),
//         );
//       },
//     );
//   }
// }

class _CartIconWithBadge extends StatelessWidget {
  const _CartIconWithBadge();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final count = state is CartLoaded ? state.cart.items.length : 0;

        String location = '';
        try {
          location = GoRouterState.of(context).uri.toString();
        } catch (_) {}

        final isSelected = location.startsWith(AppRoutes.cartRoute);

        return Badge(
          label: count > 99 ? const Text('99+') : Text(count.toString()),
          backgroundColor: AppColors.primaryAmber,
          isLabelVisible: count > 0,
          child: Icon(isSelected ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined),
        );
      },
    );
  }
}

class _WishlistIconWithBadge extends StatelessWidget {
  const _WishlistIconWithBadge();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, state) {
        final count = 4; // Mock count to match design for now

        String location = '';
        try {
          location = GoRouterState.of(context).uri.toString();
        } catch (_) {}

        final isSelected = location.startsWith(AppRoutes.wishlistRoute);

        return Badge(
          label: count > 99 ? const Text('99+') : Text(count.toString()),
          backgroundColor: AppColors.primaryAmber,
          isLabelVisible: count > 0,
          child: Icon(isSelected ? Icons.favorite_rounded : Icons.favorite_outline),
        );
      },
    );
  }
}

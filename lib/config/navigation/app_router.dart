import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/verify_otp_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/product_details/screens/product_details_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/wishlist/screens/wishlist_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/tracking/screens/order_tracking_screen.dart';
import '../../core/models/product_model.dart';
import '../../splash_screen.dart';
import 'app_routes.dart';
import 'navigation_host.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.homeRoute,
  // initialLocation: AppRoutes.splashRoute,
  routes: [
    GoRoute(
      path: AppRoutes.splashRoute,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.loginRoute,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.verifyOtpRoute,
      name: 'verify-otp',
      builder: (context, state) {
        final mobile = state.extra as String;
        return VerifyOtpScreen(mobile: mobile);
      },
    ),
    ShellRoute(
      builder: (context, state, child) => NavigationHost(child: child),
      routes: [

        GoRoute(
          path: AppRoutes.homeRoute,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.cartRoute,
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: AppRoutes.ordersRoute,
          name: 'orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: AppRoutes.wishlistRoute,
          name: 'wishlist',
          builder: (context, state) => const WishlistScreen(),
        ),
        GoRoute(
          path: AppRoutes.userProfile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    // Search ko yahan rakhein agar zaroorat ho but navigation bar se hata diya gaya hai
    GoRoute(
      path: AppRoutes.searchRoute,
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/product-details',
      name: 'product-details',
      builder: (context, state) {
        final product = state.extra as ProductModel;
        return ProductDetailsScreen(product: product);
      },
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.trackOrderRoute,
      name: 'track-order',
      builder: (context, state) {
        final orderId = state.extra as String?;
        return OrderTrackingScreen(orderId: orderId ?? "#FD29847");
      },
    ),
  ],
);

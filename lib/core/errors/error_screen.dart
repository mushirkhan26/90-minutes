import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../constants/app_constants.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  final String? title;
  final VoidCallback? onRetry;

  const ErrorScreen({super.key, required this.error, this.title, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded, size: 60, color: AppColors.errorRed),
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Error Title
              Text(title ?? 'Oops! Something went wrong', textAlign: TextAlign.center),

              const SizedBox(height: AppConstants.spacingMedium),

              // Error Message
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.2), width: 1),
                ),
                child: Text(
                  _getFormattedError(),
                  // style: theme.textTheme.bodyMedium?.copyWith(
                  //   color: AppTheme.textSecondary,
                  // ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppConstants.spacingXLarge),

              // Action Buttons
              Column(
                children: [
                  // Retry Button (if onRetry is provided)
                  if (onRetry != null) ...[
                    CustomButton(
                      text: 'Try Again',
                      onPressed: onRetry!,
                      icon: Icons.refresh_rounded,
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),
                  ],

                  // Go Home Button
                  CustomButton(text: 'Go to Home', onPressed: () => {}, icon: Icons.home_rounded),
                ],
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Support Link
              TextButton.icon(
                onPressed: () => {},
                icon: Icon(Icons.support_agent_rounded, size: 18, color: AppColors.primary),
                label: Text('Contact Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedError() {
    // Format common error messages for better user experience
    final lowerError = error.toLowerCase();

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Please check your internet connection and try again.';
    }

    if (lowerError.contains('timeout')) {
      return 'The request took too long to complete. Please try again.';
    }

    if (lowerError.contains('not found') || lowerError.contains('404')) {
      return 'The page you\'re looking for could not be found.';
    }

    if (lowerError.contains('unauthorized') || lowerError.contains('401')) {
      return 'You need to log in to access this page.';
    }

    if (lowerError.contains('forbidden') || lowerError.contains('403')) {
      return 'You don\'t have permission to access this page.';
    }

    if (lowerError.contains('server') || lowerError.contains('500')) {
      return 'Our servers are experiencing issues. Please try again later.';
    }

    // Return original error if no specific formatting applies
    return error.length > 100 ? '${error.substring(0, 100)}...' : error;
  }
}

// Specialized error screens
class NetworkErrorScreen extends ErrorScreen {
  const NetworkErrorScreen({super.key, super.onRetry})
    : super(
        error: 'Please check your internet connection and try again.',
        title: 'No Internet Connection',
      );
}

class NotFoundErrorScreen extends ErrorScreen {
  const NotFoundErrorScreen({super.key})
    : super(error: 'The page you\'re looking for could not be found.', title: 'Page Not Found');
}

class ServerErrorScreen extends ErrorScreen {
  const ServerErrorScreen({super.key, super.onRetry})
    : super(
        error: 'Our servers are experiencing issues. Please try again later.',
        title: 'Server Error',
      );
}

class UnauthorizedErrorScreen extends ErrorScreen {
  const UnauthorizedErrorScreen({super.key})
    : super(error: 'You need to log in to access this page.', title: 'Authentication Required');
}

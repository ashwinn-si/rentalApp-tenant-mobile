import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_tokens.dart';
import '../ui/screen_background.dart';
import '../ui/app_loader.dart';
import '../ui/state_card.dart';

class ListPageTemplate extends StatelessWidget {
  /// Title for the app bar
  final String title;

  /// Widget to display when loading
  final bool isLoading;

  /// Error message to display (if any)
  final String? errorMessage;

  /// Main content widget
  final Widget body;

  /// Floating action button
  final FloatingActionButton? floatingActionButton;

  /// Whether to show back button
  final bool showBackButton;

  const ListPageTemplate({
    super.key,
    required this.title,
    required this.body,
    this.isLoading = false,
    this.errorMessage,
    this.floatingActionButton,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      floatingActionButton: floatingActionButton,
      body: ScreenBackground(
        child: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 72,
      titleSpacing: AppSpacing.md,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.white,
            )
          : null,
      flexibleSpace: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(22),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    AppColors.violet,
                    AppColors.violetDark,
                  ],
                ),
              ),
            ),
            Positioned(
              top: -34,
              right: -26,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              ),
            ),
            Positioned(
              bottom: -48,
              left: -18,
              child: Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
          ],
        ),
      ),
      shadowColor: Colors.transparent,
    );
  }

  Widget _buildBody(BuildContext context) {
    // Show loader
    if (isLoading) {
      return const Center(child: AppLoader());
    }

    // Show error
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: StateCard(
            message: errorMessage!,
            variant: StateCardVariant.error,
          ),
        ),
      );
    }

    // Return body as is (pagination is handled by screens)
    return body;
  }
}

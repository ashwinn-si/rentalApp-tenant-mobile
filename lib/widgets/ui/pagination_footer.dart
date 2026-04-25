import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';

class PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;

  const PaginationFooter({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPreviousPressed,
    this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final canGoPrevious = onPreviousPressed != null;
    final canGoNext = onNextPressed != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withOpacity(isDark ? 0.2 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.violet.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1F2937),
                    const Color(0xFF111827),
                  ]
                : [
                    Colors.white,
                    Colors.white.withOpacity(0.99),
                  ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : AppColors.violet.withOpacity(0.12),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Button
            _buildNavButton(
              onPressed: onPreviousPressed,
              icon: Icons.chevron_left,
              isEnabled: canGoPrevious,
              isDark: isDark,
            ),
            // Page Indicator
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Page',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : AppColors.textSecondary.withOpacity(0.6),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      currentPage.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.violet.withOpacity(0.9) : AppColors.violet,
                      ),
                    ),
                    Text(
                      ' / $totalPages',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withOpacity(0.4)
                            : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Next Button
            _buildNavButton(
              onPressed: onNextPressed,
              icon: Icons.chevron_right,
              isEnabled: canGoNext,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required bool isEnabled,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.violet.withOpacity(isDark ? 0.3 : 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isEnabled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              AppColors.violet.withOpacity(0.8),
                              AppColors.violet.withOpacity(0.95),
                            ]
                          : [
                              AppColors.violet.withOpacity(0.9),
                              AppColors.violet,
                            ],
                    )
                  : LinearGradient(
                      colors: isDark
                          ? [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.05),
                            ]
                          : [
                              AppColors.textSecondary.withOpacity(0.1),
                              AppColors.textSecondary.withOpacity(0.08),
                            ],
                    ),
            ),
            child: Icon(
              icon,
              color: isEnabled
                  ? Colors.white
                  : isDark
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.textSecondary.withOpacity(0.3),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

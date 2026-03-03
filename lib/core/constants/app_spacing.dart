abstract class AppSpacing {
  // Base spacing unit (4px)
  static const double unit = 4.0;

  // Spacing scale
  static const double xxs = unit; // 4px
  static const double xs = unit * 2; // 8px
  static const double sm = unit * 3; // 12px
  static const double md = unit * 4; // 16px
  static const double lg = unit * 6; // 24px
  static const double xl = unit * 8; // 32px
  static const double xxl = unit * 12; // 48px
  static const double xxxl = unit * 16; // 64px

  // Screen padding
  static const double screenPadding = md;
  static const double screenPaddingLarge = lg;

  // Card padding
  static const double cardPadding = md;
  static const double cardPaddingSmall = sm;

  // List item spacing
  static const double listItemSpacing = sm;
  static const double listSectionSpacing = lg;

  // Button spacing
  static const double buttonSpacing = md;
  static const double buttonPaddingHorizontal = lg;
  static const double buttonPaddingVertical = sm;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusRound = 999.0;
}

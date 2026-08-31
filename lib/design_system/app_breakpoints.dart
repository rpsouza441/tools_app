/// Width-class breakpoints for adaptive navigation layout.
///
/// - compact: phone portrait (< 600 lp)
/// - medium: small tablet / large phone landscape (600–839 lp)
/// - expanded: desktop / large tablet (≥ 840 lp)
enum AppWidthClass { compact, medium, expanded }

/// Classifies a logical-pixel width into an [AppWidthClass].
class AppBreakpoints {
  AppBreakpoints._();

  static AppWidthClass classify(double width) {
    if (width < 600) return AppWidthClass.compact;
    if (width < 840) return AppWidthClass.medium;
    return AppWidthClass.expanded;
  }
}

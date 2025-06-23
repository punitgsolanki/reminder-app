part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH_VIEW = _Paths.SPLASH_VIEW;
  static const REMINDER_LIST_VIEW = _Paths.REMINDER_LIST_VIEW;
}

abstract class _Paths {
  static const SPLASH_VIEW = '/splash_view';
  static const REMINDER_LIST_VIEW = '/reminder_list_view';
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

//Default appbar customized with the design of our app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarTitleText;
  final List<Widget>? actions;
  final bool isBackButtonEnabled;
  final Widget? leadingView;

  const CustomAppBar({
    super.key,
    required this.appBarTitleText,
    this.actions,
    this.isBackButtonEnabled = true,
    this.leadingView,
  });

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBarColor,
      shadowColor: Colors.grey,
      centerTitle: true,
      elevation: 2,
      automaticallyImplyLeading: isBackButtonEnabled,
      actions: actions,
      iconTheme: const IconThemeData(color: AppColors.appBarIconColor),
      // title: AppBarTitle(text: appBarTitleText),
      title: Text(
        appBarTitleText,
        style: const TextStyle(
          color: AppColors.colorWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
      ),
      leading: leadingView,
    );
  }
}

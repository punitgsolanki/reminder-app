import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../../main.dart';
import '../utils/utility.dart';
import '../widget/loading.dart';
import '/app/core/base/base_controller.dart';
import '../enum/page_state.dart';

abstract class BaseView<Controller extends BaseController>
    extends GetView<Controller> {
  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  BaseView({super.key});

  final Logger logger = mainLogger;

  Widget body(BuildContext context);

  PreferredSizeWidget? appBar(BuildContext context);

  bool? setResizeToAvoidBottomInset() {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        children: [
          annotatedRegion(context),
          Obx(() => controller.pageState == PageState.LOADING
              ? _showLoading()
              : Container()),
          Obx(() => controller.errorMessage.isNotEmpty
              ? showErrorSnackBar(controller.errorMessage)
              : Container()),
          // Obx(() => controller.successMessage.isNotEmpty
          //     ? showErrorSnackBar(controller.successMessage)
          //     : Container()),
          Container(),
        ],
      ),
    );
  }

  Widget annotatedRegion(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF3533CD)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Container(
              // margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: pageScaffold(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget pageScaffold(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          key: globalKey,
          appBar: appBar(context),
          floatingActionButton: floatingActionButton(context),
          floatingActionButtonLocation: setFloatingActionButtonLocation(),
          body: pageContent(context),
          bottomNavigationBar: bottomNavigationBar(),
          drawer: drawer(),
        ),
      ],
    );
  }

  Widget pageContent(BuildContext context) {
    return SafeArea(
      child: body(context),
    );
  }

  Widget showErrorSnackBar(String message) {
    printLog("BaseView ---> showErrorSnackBar() : $message");
    final snackBar = SnackBar(content: Text(message));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    });

    return Container();
  }

   Widget? floatingActionButton(BuildContext context) {
    return null;
  }

  Widget? bottomNavigationBar() {
    return null;
  }

  Widget? drawer() {
    return null;
  }

  FloatingActionButtonLocation? setFloatingActionButtonLocation() {
    return null;
  }

  Widget _showLoading() {
    return const Loading();
  }
}

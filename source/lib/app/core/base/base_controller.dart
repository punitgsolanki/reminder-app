import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:reminder_app/app/core/extension/extension.dart';
import 'package:toastification/toastification.dart';

import '../../../main.dart';
import '../../routes/app_pages.dart';
import '../enum/page_state.dart';
import '../utils/utility.dart';

abstract class BaseController extends GetxController {
  final Logger logger = mainLogger;

  //Reload the page
  final _refreshController = false.obs;

  refreshPage(bool refresh) => _refreshController(refresh);

  //Controls page state
  final _pageSateController = PageState.DEFAULT.obs;

  PageState get pageState => _pageSateController.value;

  updatePageState(PageState state) => _pageSateController(state);

  resetPageState() => _pageSateController(PageState.DEFAULT);

  showLoading() => updatePageState(PageState.LOADING);

  hideLoading() => resetPageState();

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessageNew = ''.obs;

  final _errorMessageController = ''.obs;

  String get errorMessage => _errorMessageController.value;

  showErrorMessage(String msg) {
    _errorMessageController(msg);
    Future.delayed(const Duration(seconds: 2), () {
      _errorMessageController("");
    });
  }

  @override
  void onClose() {
    _refreshController.close();
    _pageSateController.close();
    super.onClose();
  }

  void showErrorToast(String description, {String? title}) {
    toastification.show(
      title: Text(title.trimString()),
      description: Text(description),
      style: ToastificationStyle.minimal,
      type: ToastificationType.error,
      dragToClose: true,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  void showToast(String description, {String? title}) {
    toastification.show(
      title: title.isNotEmptyAndNotNull()?Text(title.trimString()):null,
      description: Text(description),
      style: ToastificationStyle.minimal,
      type: ToastificationType.info,
      dragToClose: true,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  void showLoadingNew() {
    isLoading.value = true;
    hasError.value = false;
    errorMessageNew.value = '';
    printLog("LOADING 1: ${isLoading.value}");
  }

  void hideLoadingNew() {
    isLoading.value = false;
    printLog("LOADING 2: ${isLoading.value}");
  }

  void clearError() {
    hasError.value = false;
    errorMessageNew.value = '';
  }
}

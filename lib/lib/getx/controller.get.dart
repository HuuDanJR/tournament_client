import 'package:get/get.dart';

class MyGetXController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  RxInt playerNumber = 1.obs;

  savePlayerNumber(number) {
    playerNumber.value = number;
  }

  resetPlayerNumber() {
    playerNumber.value = 1;
  }
}

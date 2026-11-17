import 'package:get/get.dart';

class ShellController extends GetxController {
  final index = 0.obs;

  void goTo(int i) => index.value = i;
}

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(() => ShellController());
  }
}

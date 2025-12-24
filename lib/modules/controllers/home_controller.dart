import 'package:get/get.dart';
import 'package:sign_in_google_with_agora/auth/firebase_auth/firebase_auth.dart';
import 'package:sign_in_google_with_agora/services/chat_services.dart';

class HomeController extends GetxController {
  RxInt selectedItemPosition = 2.obs;
  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService.instance;
  // Stream of users
  late final Stream<List<Map<String, dynamic>>> userStream;

  @override
  void onInit() {
    super.onInit();
    userStream = _chatServices.getUserStream();
  }
}

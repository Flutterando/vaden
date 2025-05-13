import 'package:vaden/vaden.dart';

@Service()
class TesteMcpService {
  bool isTrue() => true;

  Future<bool> isFutureTrue(int seconds) async {
    return await Future.delayed(
      Duration(seconds: 1),
      () => true,
    );
  }
}

import 'package:vaden/vaden.dart';

@Controller('/health')
class HealthController {
  @Get('/')
  Future<String> health() async {
    return 'OK';
  }
}

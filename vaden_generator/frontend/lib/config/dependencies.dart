import 'package:auto_injector/auto_injector.dart';

import '../data/repositories/generate_repository.dart';
import '../data/repositories/remote_generate_repository.dart';
import '../data/services/client_http.dart';
import '../data/services/url_launcher_service.dart';
import '../main_viewmodels.dart';
import '../ui/generate/viewmodels/generate_viewmodel.dart';
import 'constants.dart';

final injector = AutoInjector();

void setupInjection() {
  injector.add(Constants.new);
  injector.add(dioFactory);
  injector.add(Constants.new);
  injector.addSingleton(ClientHttp.new);
  injector.addSingleton(UrlLauncherService.new);
  injector.addSingleton<GenerateRepository>(RemoteGenerateRepository.new);
  injector.addSingleton(MainViewmodel.new);
  injector.addSingleton(GenerateViewmodel.new);

  injector.commit();
}

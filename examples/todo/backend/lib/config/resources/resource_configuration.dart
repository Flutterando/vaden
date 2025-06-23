import 'package:vaden/vaden.dart';

@Configuration()
class ResourceConfiguration {
  @Bean()
  Storage configStorage(ApplicationSettings settings) {
    return Storage.createStorageService(settings);
  }

  @Bean()
  ResourceService resources() {
    return ResourceService(
      fileSystemPath: './public',
      defaultDocument: 'index.html',
    );
  }
}

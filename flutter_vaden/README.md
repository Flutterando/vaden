# Flutter Vaden

Flutter Vaden is a powerful package that brings the Vaden framework's dependency injection and API client capabilities to Flutter applications. It simplifies the development of RESTful APIs and provides robust tools for managing dependencies and data transfer objects (DTOs).

## Installation

To get started, add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_vaden: ^latest_version

dev_dependencies:
  vaden_class_scanner: ^latest_version
  build_runner: ^latest_version
```

Run the following commands to install the dependencies and generate the necessary code:

```bash
flutter pub get
dart run build_runner build
```

The `build_runner` command will generate a class named `VadenApp`. You should use this class in your `runApp` method:

```dart
void main() {
  runApp(VadenApp(
    child: MyApp(),
  ));
}
```

## Features

### Dependency Injection
Flutter Vaden provides a complete dependency injection system, including:

- `@Configuration()`: Used to define configuration classes.
- `@Service()`: Marks classes as services. Prefer registering services via their interfaces.
- `@Repository()`: Marks classes as repositories. Prefer registering repositories via their interfaces.

#### Accessing Instances in Widgets
You can access registered instances directly in your Flutter widgets using:

```dart
context.read<NameOfComponent>()
```

### Data Transfer Objects (DTOs)
The package supports `@DTO()` annotations for defining data transfer objects. These DTOs are used for serializing and deserializing data in API requests and responses.

### API Client
The highlight of Flutter Vaden is the `@ApiClient()` annotation, which allows you to create abstractions for RESTful APIs similar to Retrofit. Internally, it uses Dio for making HTTP requests. Therefore, if you want to customize Dio, such as setting a `baseUrl` or adding interceptors, you can create a `@Configuration()` for Dio.

#### Example

```dart
@Configuration()
class DioConfiguration {
  @Bean()
  Dio dio() {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
    dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio;
  }
}

@ApiClient()
abstract class ProductApi {
  @Get('/product/<id>')
  Future<ProductDTO> getProduct(@Param() int id);

  @Post('/product')
  Future<ProductDTO> createProduct(@Body() ProductDTO product);

  @Put('/product/<id>')
  Future<ProductDTO> updateProduct(@Param() int id, @Body() ProductDTO product);

  @Delete('/product/<id>')
  Future<void> deleteProduct(@Param() int id);

  @Get('/products')
  Future<List<ProductDTO>> getAllProducts();
}
```

### Notes
- All return objects and `@Body()` parameters must be annotated with `@DTO()`.
- The `@ApiClient()` annotation simplifies API integration by generating the necessary code for making HTTP requests.

Flutter Vaden is designed to streamline your Flutter development process, making it easier to manage dependencies and interact with RESTful APIs. Enjoy building robust and scalable applications with Flutter Vaden!


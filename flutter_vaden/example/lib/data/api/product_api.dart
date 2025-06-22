import 'package:flutter_example/models/product_model.dart';
import 'package:flutter_vaden/flutter_vaden.dart';

@ApiClient()
abstract class ProductApi {
  @Get('/api/vi/users')
  Future<List<ProductModel>> getTest();

  @Get('/product/<id>')
  Future<ProductModel> getProduct(@Param() int id);

  @Post('/product')
  Future<ProductModel> createProduct(@Body() ProductModel product);

  @Put('/product/<id>')
  Future<ProductModel> updateProduct(
    @Param() int id,
    @Body() ProductModel product,
  );

  @Put('/product')
  Future<ProductModel> updateProducts(@Body() List<ProductModel> product);

  @Delete('/product/<id>')
  Future<void> deleteProduct(@Param() int id);

  @Get('/products')
  Future<List<ProductModel>> getAllProducts();
}

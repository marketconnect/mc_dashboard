// import 'package:dio/dio.dart';
// import 'package:fpdart/fpdart.dart';
// import 'package:mc_dashboard/infrastructure/api/products.dart';
// import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';

// import 'package:mc_dashboard/domain/entities/product_item.dart';

// class ProductService {
//   final ProductsApiClient productsApiClient;

//   ProductService({required this.productsApiClient});

//   Future<Either<AppErrorBase, List<ProductItem>>> getProducts({
//     int? brandId,
//     int? subjectId,
//     int? supplierId,
//     int page = 1,
//     int pageSize = 100,
//   }) async {
//     try {
//       final result = await productsApiClient.getProducts(
//         brandId: brandId,
//         subjectId: subjectId,
//         supplierId: supplierId,
//         page: page,
//         pageSize: pageSize,
//       );

//       return Right(result.products);
//     } on DioException catch (e, stackTrace) {
//       if (e.response?.statusCode == 404) {
//         return const Right([]);
//       }

//       // Обработка остальных ошибок
//       final responseMessage = e.response?.data?['message'] ?? e.message;
//       final error = AppErrorBase(
//         'DioException: $responseMessage',
//         name: 'getProducts',
//         sendTo: true,
//         source: 'ProductService',
//         args: [
//           'brandId: $brandId',
//           'subjectId: $subjectId',
//           'supplierId: $supplierId',
//           'page: $page',
//           'pageSize: $pageSize',
//         ],
//         stackTrace: stackTrace.toString(),
//       );
//       AppLogger.log(error);
//       return Left(error);
//     } catch (e, stackTrace) {
//       final error = AppErrorBase(
//         'Unexpected error: $e',
//         name: 'getProducts',
//         sendTo: true,
//         source: 'ProductService',
//         args: [
//           'brandId: $brandId',
//           'subjectId: $subjectId',
//           'supplierId: $supplierId',
//           'page: $page',
//           'pageSize: $pageSize',
//         ],
//         stackTrace: stackTrace.toString(),
//       );
//       AppLogger.log(error);
//       return Left(error);
//     }
//   }
// }

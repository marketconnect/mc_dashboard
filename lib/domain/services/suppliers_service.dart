// import 'package:fpdart/fpdart.dart';
// import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
// import 'package:mc_dashboard/domain/entities/supplier_item.dart';
// import 'package:mc_dashboard/infrastructure/api/suppliers_api_client.dart';

// class SuppliersService {
//   final SuppliersApiClient suppliersApiClient;

//   SuppliersService({
//     required this.suppliersApiClient,
//   });

//   Future<Either<AppErrorBase, List<SupplierItem>>> getSuppliers({
//     required List<int> supplierIds,
//   }) async {
//     try {
//       final response = await suppliersApiClient.getSuppliers(
//         supplierIds: supplierIds,
//       );
//       return Right(response.suppliers);
//     } catch (e, stackTrace) {
//       final error = AppErrorBase(
//         'Unexpected error: $e',
//         name: 'getSuppliers',
//         sendTo: true,
//         source: 'SuppliersService',
//         args: [
//           'supplierIds: $supplierIds',
//         ],
//         stackTrace: stackTrace.toString(),
//       );
//       AppLogger.log(error);
//       return Left(error);
//     }
//   }
// }

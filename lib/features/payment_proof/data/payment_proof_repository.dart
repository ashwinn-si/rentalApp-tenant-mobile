import 'package:dio/dio.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/network/dio_client.dart';
import 'models/payment_proof.dart';
import 'models/rent_record.dart';

class PaymentProofRepository {
  final DioClient _client = DioClient.instance;

  Future<RentRecord?> getRentByMonthYear({
    required int month,
    required int year,
    String? flatId,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiPaths.rentByMonthYear,
      fromJson: (json) => json as Map<String, dynamic>,
      queryParams: {
        'month': month,
        'year': year,
        if (flatId != null) 'flatId': flatId,
      },
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    final data = response.data;
    if (data == null || data['data'] == null) {
      return null;
    }

    return RentRecord.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<List<PaymentProof>> getMyProofs({String? rentRecordId}) async {
    final response = await _client.get<List<dynamic>>(
      ApiPaths.paymentProofs,
      fromJson: (json) => json as List<dynamic>,
      queryParams: {
        if (rentRecordId != null) 'rentRecordId': rentRecordId,
      },
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    final data = response.data ?? [];
    return data
        .map((item) => PaymentProof.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getS3UploadUrl({
    required String fileName,
    String? contentType,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiPaths.s3UploadUrls,
      fromJson: (json) => json as Map<String, dynamic>,
      data: {
        'fileName': fileName,
        if (contentType != null) 'contentType': contentType,
        'subFolder': 'payment-proofs',
      },
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    return response.data ?? {};
  }

  Future<void> uploadToS3({
    required String url,
    required List<int> fileBytes,
    required String contentType,
  }) async {
    try {
      final dio = Dio();
      await dio.put(
        url,
        data: Stream.fromIterable([fileBytes]),
        options: Options(
          headers: {
            'Content-Type': contentType,
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentProof> submitProof({
    required String rentRecordId,
    required String paidToName,
    required List<PaymentMethod> paymentMethods,
    List<Map<String, String>>? proofImages,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiPaths.paymentProofs,
      fromJson: (json) => json as Map<String, dynamic>,
      data: {
        'rentRecordId': rentRecordId,
        'paidToName': paidToName,
        'paymentMethods': paymentMethods.map((m) => m.toJson()).toList(),
        if (proofImages != null && proofImages.isNotEmpty)
          'proofImages': proofImages,
      },
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    return PaymentProof.fromJson(response.data ?? {});
  }
}

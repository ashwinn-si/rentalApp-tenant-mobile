import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/image_utils.dart';
import 'models/payment_proof.dart';
import 'models/rent_record.dart';

const _uploadSendTimeout = Duration(seconds: 120);
const _uploadReceiveTimeout = Duration(seconds: 120);

class PaymentProofRepository {
  final DioClient _client = DioClient.instance;

  Future<Map<String, dynamic>> getActiveRentMonth() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiPaths.activeRentMonth,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    final rawData = response.data ?? {};
    return (rawData['data'] as Map<String, dynamic>?) ?? rawData;
  }

  Future<RentRecord?> getRentByMonthYear({
    required int month,
    required int year,
    String? flatId,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '${ApiPaths.paymentProofs}/rent-detail',
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
    developer.log('[PaymentProofRepository.getMyProofs] Calling endpoint: ${ApiPaths.paymentProofs}');

    final response = await _client.get<Map<String, dynamic>>(
      ApiPaths.paymentProofs,
      fromJson: (json) => json as Map<String, dynamic>,
      queryParams: {
        if (rentRecordId != null) 'rentRecordId': rentRecordId,
      },
    );

    developer.log('[PaymentProofRepository.getMyProofs] Response received - isSuccess: ${response.isSuccess}, statusCode: ${response.statusCode}');

    if (!response.isSuccess) {
      developer.log('[PaymentProofRepository.getMyProofs] API Error: ${response.message}');
      throw Exception(response.message);
    }

    developer.log('[PaymentProofRepository.getMyProofs] Response data: ${response.data}');

    final responseData = response.data ?? {};
    // Handle wrapped response: { "data": [...] }
    final proofsList = responseData['data'] as List<dynamic>? ?? responseData as List<dynamic>?;

    developer.log('[PaymentProofRepository.getMyProofs] Parsed proofs count: ${proofsList?.length ?? 0}');

    if (proofsList == null) {
      return [];
    }

    return proofsList
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

    final data = response.data ?? {};
    // Handle wrapped response format: { "data": { "url": ..., "key": ... } }
    if (data.containsKey('data') && data['data'] is Map) {
      return data['data'] as Map<String, dynamic>;
    }
    return data;
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

  Future<PaymentProof> submitProofWithFiles({
    required String rentRecordId,
    required String paidToName,
    required List<PaymentMethod> paymentMethods,
    required List<List<int>> fileBytes,
    required List<String> fileNames,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('rentRecordId', rentRecordId));
    formData.fields.add(MapEntry('paidToName', paidToName));
    formData.fields.add(MapEntry(
      'paymentMethods',
      jsonEncode(paymentMethods.map((m) => m.toJson()).toList()),
    ));

    for (int i = 0; i < fileBytes.length; i++) {
      final raw = Uint8List.fromList(fileBytes[i]);
      final name = fileNames[i];
      final Uint8List finalBytes = ImageUtils.isCompressible(name)
          ? await ImageUtils.compressBytes(raw)
          : raw;
      formData.files.add(
        MapEntry('proofImages', MultipartFile.fromBytes(finalBytes, filename: name)),
      );
    }

    final response = await _client.post<Map<String, dynamic>>(
      '${ApiPaths.paymentProofs}/with-files',
      fromJson: (json) => json as Map<String, dynamic>,
      data: formData,
      sendTimeout: _uploadSendTimeout,
      receiveTimeout: _uploadReceiveTimeout,
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    return PaymentProof.fromJson(response.data ?? {});
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

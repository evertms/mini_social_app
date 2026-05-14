import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  static final DioClient instance = DioClient._internal();

  final Dio _dio;

  DioClient._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['API_BASE_URL'] ?? '',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  Dio get client => _dio;
}

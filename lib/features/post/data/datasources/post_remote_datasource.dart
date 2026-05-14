import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> fetchPosts();
  Future<PostModel> createPost(PostModel post);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio _dio;

  PostRemoteDataSourceImpl({required DioClient dioClient})
    : _dio = dioClient.client;

  @override
  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await _dio.get('/posts');
      final data = response.data;

      if (data is List) {
        return data
            .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Formato recibido no soportado');
    } catch (error) {
      throw Exception('Fallo al obtener posts: $error');
    }
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    try {
      final response = await _dio.post('/posts', data: post.toJson());

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PostModel.fromJson(data);
      }

      throw Exception('Formato recibido no soportado');
    } catch (error) {
      throw Exception('Fallo al crear post: $error');
    }
  }
}

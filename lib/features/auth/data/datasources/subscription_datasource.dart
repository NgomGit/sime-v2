import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/api_constants.dart';
import 'package:sime_v2/features/auth/data/models/subscription_model.dart';


abstract interface class SubscriptionRemoteDataSource {
  Future<List<SubscriptionModel>> getMySubscriptions();
  Future<SubscriptionModel> createSubscription(Map<String, dynamic> body);
}
 
class SubscriptionRemoteDataSourceImpl
    implements SubscriptionRemoteDataSource {
  const SubscriptionRemoteDataSourceImpl(this._client);
  final ApiClient _client;
 
  @override
  Future<List<SubscriptionModel>> getMySubscriptions() async {
    final r = await _client.dio.get(ApiConstants.subscriptionsMe);
    return (r.data as List<dynamic>)
        .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
 
  @override
  Future<SubscriptionModel> createSubscription(
    Map<String, dynamic> body,
  ) async {
    final r = await _client.dio.post(ApiConstants.subscriptions, data: body);
    return SubscriptionModel.fromJson(r.data as Map<String, dynamic>);
  }
}
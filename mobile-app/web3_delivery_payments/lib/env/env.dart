import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'PRIVATE_KEY', obfuscate: true)
  static final String privateKey = _Env.privateKey;
  @EnviedField(varName: 'ALCHEMY_TESTNET_RPC_URL', obfuscate: true)
  static final String rpcURL = _Env.rpcURL;
  @EnviedField(varName: 'ROUTE_API_KEY', obfuscate: true)
  static final String routeAPIKey = _Env.routeAPIKey;
}

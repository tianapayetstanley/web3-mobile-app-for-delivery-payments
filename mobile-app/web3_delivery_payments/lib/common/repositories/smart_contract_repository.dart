import 'package:flutter/services.dart';
import 'package:web3_delivery_payments/common/models/checkpoint_model.dart';
import 'package:web3_delivery_payments/env/env.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class SmartContractRepository {
  final String _rpcUrl = Env.rpcURL;

  final String _privatekey = Env.privateKey;
  late Web3Client _web3cient;

  SmartContractRepository() {
    init();
  }

  Future<void> init() async {
    _web3cient = Web3Client(
      _rpcUrl,
      http.Client(),
    );
    await getABI();
    await getCredentials();
    await getDeployedContract();
  }

  late ContractAbi _abiCode;
  late EthereumAddress _contractAddress;
  Future<void> getABI() async {
    String abiFile =
        await rootBundle.loadString('assets/contracts/GeoLogix.json');
    _abiCode = ContractAbi.fromJson(abiFile, 'GeoLogix');
    _contractAddress =
        EthereumAddress.fromHex('0x97f386802197484210A0acC9AB2891eDaB14431b');
  }

  late EthPrivateKey _creds;
  Future<void> getCredentials() async {
    _creds = EthPrivateKey.fromHex(_privatekey);
  }

  late DeployedContract _deployedContract;

  late ContractFunction _checkpointIds;
  late ContractFunction _checkpointsMap;

  late ContractFunction _ingestTelemetry;

  late ContractFunction _complianceIds;
  late ContractFunction _compliancesMap;

  late ContractFunction _nonComplianceIds;
  late ContractFunction _nonCompliancesMap;

  Future<void> getDeployedContract() async {
    _deployedContract = DeployedContract(_abiCode, _contractAddress);

    _checkpointIds = _deployedContract.function('getCheckpointIds');
    _checkpointsMap = _deployedContract.function('checkpointsMap');

    _ingestTelemetry = _deployedContract.function('IngestTelemetry');

    _complianceIds = _deployedContract.function('getComplianceIds');
    _compliancesMap = _deployedContract.function('compliancesMap');

    _nonComplianceIds = _deployedContract.function('getNonComplianceIds');
    _nonCompliancesMap = _deployedContract.function('nonCompliancesMap');
    await fetchCheckpoints();
  }

  Future<List<Checkpoint>> fetchCheckpoints() async {
    List<Checkpoint> checkpoints = [];
    List checkpointIds = await _web3cient.call(
      contract: _deployedContract,
      function: _checkpointIds,
      params: [],
    );
    // checkpointIds was an array that had [[0,1,2...]]
    checkpointIds = checkpointIds[0];

    for (var i = 0; i < checkpointIds.length; i++) {
      var temp = await _web3cient.call(
          contract: _deployedContract,
          function: _checkpointsMap,
          params: [BigInt.from(i)]);
      checkpoints.add(
        Checkpoint(
          id: (temp[0] as BigInt).toInt(),
          lat: ((temp[1] as BigInt).toInt() / 100000).toDouble(),
          lng: ((temp[2] as BigInt).toInt() / 100000).toDouble(),
          timestamp: (temp[3] as BigInt).toInt(),
        ),
      );
    }
    return checkpoints;
  }

  Future<List<List<Checkpoint>>> fetchCompliancesAndNonCompliances() async {
    List<Checkpoint> compliances = [];
    List<Checkpoint> nonCompliances = [];

    List complianceIds = await _web3cient.call(
      contract: _deployedContract,
      function: _complianceIds,
      params: [],
    );
    List nonComplianceIds = await _web3cient.call(
      contract: _deployedContract,
      function: _nonComplianceIds,
      params: [],
    );

    for (var i = 0; i < complianceIds.length; i++) {
      var temp = await _web3cient.call(
          contract: _deployedContract,
          function: _compliancesMap,
          params: [BigInt.from(i)]);
      compliances.add(
        Checkpoint(
          id: (temp[0] as BigInt).toInt(),
          lat: ((temp[1] as BigInt).toInt() / 100000).toDouble(),
          lng: ((temp[2] as BigInt).toInt() / 100000).toDouble(),
          timestamp: (temp[3] as BigInt).toInt(),
        ),
      );
    }

    for (var i = 0; i < nonComplianceIds.length; i++) {
      var temp = await _web3cient.call(
          contract: _deployedContract,
          function: _nonCompliancesMap,
          params: [BigInt.from(i)]);
      nonCompliances.add(
        Checkpoint(
          id: (temp[0] as BigInt).toInt(),
          lat: ((temp[1] as BigInt).toInt() / 100000).toDouble(),
          lng: ((temp[2] as BigInt).toInt() / 100000).toDouble(),
          timestamp: (temp[3] as BigInt).toInt(),
        ),
      );
    }

    return [compliances, nonCompliances];
  }

  Future<void> sendTelemetry(int id, int lat, int lng, int timestamp) async {
    await _web3cient.sendTransaction(
      _creds,
      Transaction.callContract(
        contract: _deployedContract,
        function: _ingestTelemetry,
        parameters: [
          BigInt.from(id),
          BigInt.from(lat),
          BigInt.from(lng),
          BigInt.from(timestamp)
        ],
      ),
    );
  }
}

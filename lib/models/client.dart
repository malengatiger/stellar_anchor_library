import 'agent.dart';

class Client {
  /*
  private String anchorId,
            agentId,
            clientId, startingFiatBalance;
    private double latitude, longitude;
    private String dateRegistered,
            dateUpdated,
            externalAccountId,
            account,
            memo,
            password,
            secretSeed;

    private String memo_type;
    private PersonalKYCFields personalKYCFields;
   */
  String anchorId, agentId;
  String clientId, startingFiatBalance;
  double latitude, longitude;
  String dateRegistered,
      dateUpdated,
      externalAccountId,
      account,
      fiatLimit,
      password,
      secretSeed;
  PersonalKYCFields personalKYCFields;

  Client(
      this.anchorId,
      this.agentId,
      this.clientId,
      this.startingFiatBalance,
      this.dateRegistered,
      this.dateUpdated,
      this.externalAccountId,
      this.account,
      this.latitude,
      this.longitude,
      this.fiatLimit,
      this.password,
      this.secretSeed,
      this.personalKYCFields); //
  //

  Client.fromJson(Map data) {
    this.anchorId = data['anchorId'];
    this.agentId = data['agentId'];
    this.clientId = data['clientId'];
    this.startingFiatBalance = data['startingFiatBalance'];
    this.dateRegistered = data['dateRegistered'];
    this.dateUpdated = data['dateUpdated'];
    this.externalAccountId = data['externalAccountId'];
    this.account = data['account'];
    this.latitude = data['latitude'];
    this.longitude = data['longitude'];

    this.password = data['password'];
    this.secretSeed = data['secretSeed'];
    if (data['personalKYCFields'] != null) {
      this.personalKYCFields =
          PersonalKYCFields.fromJson(data['personalKYCFields']);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['anchorId'] = anchorId;
    map['agentId'] = agentId;
    map['clientId'] = clientId;
    map['startingFiatBalance'] = startingFiatBalance;
    map['dateRegistered'] = dateRegistered;
    map['dateUpdated'] = dateUpdated;
    map['externalAccountId'] = externalAccountId;
    map['account'] = account;
    map['latitude'] = latitude;
    map['longitude'] = longitude;

    map['password'] = password;
    map['secretSeed'] = secretSeed;
    map['personalKYCFields'] =
        personalKYCFields == null ? null : personalKYCFields.toJson();

    return map;
  }
}

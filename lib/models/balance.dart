class Balance {
  /*
  @SerializedName("asset_type")
    private final String assetType;
    @SerializedName("asset_code")
    private final String assetCode;
    @SerializedName("asset_issuer")
    private final String assetIssuer;
    @SerializedName("limit")
    private final String limit;
    @SerializedName("balance")
    private final String balance;
    @SerializedName("buying_liabilities")
    private final String buyingLiabilities;
    @SerializedName("selling_liabilities")
    private final String sellingLiabilities;
    @SerializedName("is_authorized")
    private final Boolean isAuthorized;
    @SerializedName("last_modified_ledger")
    private final Integer lastModifiedLedger;
   */
  String assetType, balance, assetCode;
  bool isAuthorized;
  int lastModifiedLedger;
  String buyingLiabilities, sellingLiabilities;

  Balance(
      this.assetType,
      this.balance,
      this.assetCode,
      this.isAuthorized,
      this.lastModifiedLedger,
      this.buyingLiabilities,
      this.sellingLiabilities); //
  //

  Balance.fromJson(Map data) {
    this.assetType = data['assetType'];
    this.assetCode = data['assetCode'];
    this.balance = data['balance'];
    this.isAuthorized = data['isAuthorized'];
    this.buyingLiabilities = data['buyingLiabilities'];
    this.sellingLiabilities = data['sellingLiabilities'];
    this.lastModifiedLedger = data['lastModifiedLedger'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['assetType'] = assetType;
    map['assetCode'] = assetCode;
    map['balance'] = balance;
    map['isAuthorized'] = isAuthorized;
    map['buyingLiabilities'] = buyingLiabilities;
    map['sellingLiabilities'] = sellingLiabilities;
    map['lastModifiedLedger'] = lastModifiedLedger;

    return map;
  }
}

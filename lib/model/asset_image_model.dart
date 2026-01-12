class AssetImageModel {
  String? message;
  String? apiReqId;
  String? apiReqCols;
  List<ApiDataArray>? apiDataArray;
  String? apiReqOrgnId;

  AssetImageModel({
    this.message,
    this.apiReqId,
    this.apiReqCols,
    this.apiDataArray,
    this.apiReqOrgnId,
  });

  AssetImageModel.fromJson(Map<String, dynamic> json) {
    message = json['Message'];
    apiReqId = json['apiReqId'];
    apiReqCols = json['apiReqCols'];
    if (json['apiDataArray'] != null) {
      apiDataArray = <ApiDataArray>[];
      json['apiDataArray'].forEach((v) {
        apiDataArray!.add(ApiDataArray.fromJson(v));
      });
    }
    apiReqOrgnId = json['apiReqOrgnId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Message'] = message;
    data['apiReqId'] = apiReqId;
    data['apiReqCols'] = apiReqCols;
    if (apiDataArray != null) {
      data['apiDataArray'] = apiDataArray!.map((v) => v.toJson()).toList();
    }
    data['apiReqOrgnId'] = apiReqOrgnId;
    return data;
  }
}

class ApiDataArray {
  String? aCTIVEFLAG;
  String? hIDDENFLAG;
  String? sEQUENCENO;
  String? aUDITID;
  String? fILENAME;
  String? rEGION;
  String? eDITBY;
  String? cREATEDATE;
  String? lOCALE;
  String? dEFAULTFLAG;
  String? aTTACHTYPE;
  String? cREATEBY;
  String? eDITDATE;
  String? cONTENT;
  String? aTTACHEXTENSION;
  String? tYPE;
  String? rECORDNO;

  ApiDataArray({
    this.aCTIVEFLAG,
    this.hIDDENFLAG,
    this.sEQUENCENO,
    this.aUDITID,
    this.fILENAME,
    this.rEGION,
    this.eDITBY,
    this.cREATEDATE,
    this.lOCALE,
    this.dEFAULTFLAG,
    this.aTTACHTYPE,
    this.cREATEBY,
    this.eDITDATE,
    this.cONTENT,
    this.aTTACHEXTENSION,
    this.tYPE,
    this.rECORDNO,
  });

  ApiDataArray.fromJson(Map<String, dynamic> json) {
    aCTIVEFLAG = json['ACTIVE_FLAG'];
    hIDDENFLAG = json['HIDDEN_FLAG'];
    sEQUENCENO = json['SEQUENCE_NO'];
    aUDITID = json['AUDIT_ID'];
    fILENAME = json['FILE_NAME'];
    rEGION = json['REGION'];
    eDITBY = json['EDIT_BY'];
    cREATEDATE = json['CREATE_DATE'];
    lOCALE = json['LOCALE'];
    dEFAULTFLAG = json['DEFAULT_FLAG'];
    aTTACHTYPE = json['ATTACH_TYPE'];
    cREATEBY = json['CREATE_BY'];
    eDITDATE = json['EDIT_DATE'];
    cONTENT = json['CONTENT'];
    aTTACHEXTENSION = json['ATTACH_EXTENSION'];
    tYPE = json['TYPE'];
    rECORDNO = json['RECORD_NO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ACTIVE_FLAG'] = aCTIVEFLAG;
    data['HIDDEN_FLAG'] = hIDDENFLAG;
    data['SEQUENCE_NO'] = sEQUENCENO;
    data['AUDIT_ID'] = aUDITID;
    data['FILE_NAME'] = fILENAME;
    data['REGION'] = rEGION;
    data['EDIT_BY'] = eDITBY;
    data['CREATE_DATE'] = cREATEDATE;
    data['LOCALE'] = lOCALE;
    data['DEFAULT_FLAG'] = dEFAULTFLAG;
    data['ATTACH_TYPE'] = aTTACHTYPE;
    data['CREATE_BY'] = cREATEBY;
    data['EDIT_DATE'] = eDITDATE;
    data['CONTENT'] = cONTENT;
    data['ATTACH_EXTENSION'] = aTTACHEXTENSION;
    data['TYPE'] = tYPE;
    data['RECORD_NO'] = rECORDNO;
    return data;
  }

  // Added copyWith method for easy modification
  ApiDataArray copyWith({
    String? aCTIVEFLAG,
    String? hIDDENFLAG,
    String? sEQUENCENO,
    String? aUDITID,
    String? fILENAME,
    String? rEGION,
    String? eDITBY,
    String? cREATEDATE,
    String? lOCALE,
    String? dEFAULTFLAG,
    String? aTTACHTYPE,
    String? cREATEBY,
    String? eDITDATE,
    String? cONTENT,
    String? aTTACHEXTENSION,
    String? tYPE,
    String? rECORDNO,
  }) {
    return ApiDataArray(
      aCTIVEFLAG: aCTIVEFLAG ?? this.aCTIVEFLAG,
      hIDDENFLAG: hIDDENFLAG ?? this.hIDDENFLAG,
      sEQUENCENO: sEQUENCENO ?? this.sEQUENCENO,
      aUDITID: aUDITID ?? this.aUDITID,
      fILENAME: fILENAME ?? this.fILENAME,
      rEGION: rEGION ?? this.rEGION,
      eDITBY: eDITBY ?? this.eDITBY,
      cREATEDATE: cREATEDATE ?? this.cREATEDATE,
      lOCALE: lOCALE ?? this.lOCALE,
      dEFAULTFLAG: dEFAULTFLAG ?? this.dEFAULTFLAG,
      aTTACHTYPE: aTTACHTYPE ?? this.aTTACHTYPE,
      cREATEBY: cREATEBY ?? this.cREATEBY,
      eDITDATE: eDITDATE ?? this.eDITDATE,
      cONTENT: cONTENT ?? this.cONTENT,
      aTTACHEXTENSION: aTTACHEXTENSION ?? this.aTTACHEXTENSION,
      tYPE: tYPE ?? this.tYPE,
      rECORDNO: rECORDNO ?? this.rECORDNO,
    );
  }

  // Added equality and hashCode for easier comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ApiDataArray &&
      other.aCTIVEFLAG == aCTIVEFLAG &&
      other.hIDDENFLAG == hIDDENFLAG &&
      other.sEQUENCENO == sEQUENCENO &&
      other.aUDITID == aUDITID &&
      other.fILENAME == fILENAME &&
      other.rEGION == rEGION &&
      other.eDITBY == eDITBY &&
      other.cREATEDATE == cREATEDATE &&
      other.lOCALE == lOCALE &&
      other.dEFAULTFLAG == dEFAULTFLAG &&
      other.aTTACHTYPE == aTTACHTYPE &&
      other.cREATEBY == cREATEBY &&
      other.eDITDATE == eDITDATE &&
      other.cONTENT == cONTENT &&
      other.aTTACHEXTENSION == aTTACHEXTENSION &&
      other.tYPE == tYPE &&
      other.rECORDNO == rECORDNO;
  }

  @override
  int get hashCode {
    return Object.hash(
      aCTIVEFLAG,
      hIDDENFLAG,
      sEQUENCENO,
      aUDITID,
      fILENAME,
      rEGION,
      eDITBY,
      cREATEDATE,
      lOCALE,
      dEFAULTFLAG,
      aTTACHTYPE,
      cREATEBY,
      eDITDATE,
      cONTENT,
      aTTACHEXTENSION,
      tYPE,
      rECORDNO,
    );
  }
}
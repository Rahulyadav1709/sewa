class ImageUploadResponseModel {
  String? message;
  String? apiReqId;
  String? apiReqOrgnId;

  ImageUploadResponseModel({this.message, this.apiReqId, this.apiReqOrgnId});

  ImageUploadResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['Message'];
    apiReqId = json['apiReqId'];
    apiReqOrgnId = json['apiReqOrgnId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Message'] = this.message;
    data['apiReqId'] = this.apiReqId;
    data['apiReqOrgnId'] = this.apiReqOrgnId;
    return data;
  }
}

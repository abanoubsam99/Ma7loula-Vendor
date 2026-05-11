class WithdrawalMethodsModel {
  String? message;
  Data? data;

  WithdrawalMethodsModel({this.message, this.data});

  WithdrawalMethodsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<String>? methods;

  Data({this.methods});

  Data.fromJson(Map<String, dynamic> json) {
    methods = json['methods'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['methods'] = methods;
    return data;
  }
}

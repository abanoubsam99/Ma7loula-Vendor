class SentWithdrawalMethodModel {
  String? message;
  Data? data;

  SentWithdrawalMethodModel({this.message, this.data});

  SentWithdrawalMethodModel.fromJson(Map<String, dynamic> json) {
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
  Request? request;

  Data({this.request});

  Data.fromJson(Map<String, dynamic> json) {
    request =
        json['request'] != null ? Request.fromJson(json['request']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (request != null) {
      data['request'] = request!.toJson();
    }
    return data;
  }
}

class Request {
  int? id;
  int? amount;
  String? method;
  String? status;
  String? date;

  Request({this.id, this.amount, this.method, this.status, this.date});

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    method = json['method'];
    status = json['status'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['amount'] = amount;
    data['method'] = method;
    data['status'] = status;
    data['date'] = date;
    return data;
  }
}

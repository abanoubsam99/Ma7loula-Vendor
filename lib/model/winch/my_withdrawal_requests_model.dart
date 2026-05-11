class MyWithdrawalRequestsModel {
  String? message;
  Pagination? pagination;
  Data? data;

  MyWithdrawalRequestsModel({this.message, this.pagination, this.data});

  MyWithdrawalRequestsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Pagination {
  int? page;
  int? ofPages;
  int? perPage;
  int? total;

  Pagination({this.page, this.ofPages, this.perPage, this.total});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    ofPages = json['ofPages'];
    perPage = json['perPage'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['ofPages'] = ofPages;
    data['perPage'] = perPage;
    data['total'] = total;
    return data;
  }
}

class Data {
  List<Requests>? requests;

  Data({this.requests});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['requests'] != null) {
      requests = <Requests>[];
      json['requests'].forEach((v) {
        requests!.add(Requests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (requests != null) {
      data['requests'] = requests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Requests {
  int? id;
  int? amount;
  String? method;
  String? status;
  String? date;

  Requests({this.id, this.amount, this.method, this.status, this.date});

  Requests.fromJson(Map<String, dynamic> json) {
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

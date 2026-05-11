class MyTransactionsModel {
  String? message;
  Pagination? pagination;
  Data? data;

  MyTransactionsModel({this.message, this.pagination, this.data});

  MyTransactionsModel.fromJson(Map<String, dynamic> json) {
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
  int? balance;
  List<Transactions>? transactions;

  Data({this.balance, this.transactions});

  Data.fromJson(Map<String, dynamic> json) {
    balance = json['balance'];
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(Transactions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['balance'] = balance;
    if (transactions != null) {
      data['transactions'] = transactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transactions {
  int? id;
  String? type;
  int? amount;
  int? orderId;
  int? balance;
  String? date;

  Transactions(
      {this.id, this.type, this.amount, this.orderId, this.balance, this.date});

  Transactions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    amount = json['amount'];
    orderId = json['order_id'];
    balance = json['balance'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['amount'] = amount;
    data['order_id'] = orderId;
    data['balance'] = balance;
    data['date'] = date;
    return data;
  }
}

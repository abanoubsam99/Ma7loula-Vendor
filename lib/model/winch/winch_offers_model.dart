class WinchOffersModel {
  String? message;
  Data? data;

  WinchOffersModel({this.message, this.data});

  WinchOffersModel.fromJson(Map<String, dynamic> json) {
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
  AcceptedOffer? acceptedOffer;
  List<AcceptedOffer>? requests;

  Data({this.acceptedOffer, this.requests});

  Data.fromJson(Map<String, dynamic> json) {
    acceptedOffer = json['accepted_offer'] != null
        ? AcceptedOffer.fromJson(json['accepted_offer'])
        : null;
    if (json['requests'] != null) {
      requests = <AcceptedOffer>[];
      json['requests'].forEach((v) {
        requests!.add(AcceptedOffer.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (acceptedOffer != null) {
      data['accepted_offer'] = acceptedOffer!.toJson(); // Fix: Call toJson()
    }
    if (requests != null) {
      data['requests'] = requests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AcceptedOffer {
  int? id;
  String? status;
  String? paymentMethod;
  num? servicesPrice;
  num? taxPrice;
  num? total;
  UserCar? userCar;
  List<Statueses>? statueses;
  var rate;
  var fromLat;
  var fromLon;
  var toLat;
  var toLon;
  User? user;
  String? fromText;
  String? toText;
  String? distanceInMeters;
  String? durationInMinutes;
  Brand? vendor;
  Worker? worker;

  AcceptedOffer(
      {this.id,
      this.status,
      this.paymentMethod,
      this.servicesPrice,
      this.taxPrice,
      this.total,
      this.userCar,
      this.statueses,
      this.rate,
      this.fromLat,
      this.fromLon,
      this.toLat,
      this.toLon,
        this.user,
      this.fromText,
      this.toText,
      this.distanceInMeters,
      this.durationInMinutes,
      this.vendor,
      this.worker});

  AcceptedOffer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    paymentMethod = json['payment_method'];
    servicesPrice = json['services_price'];
    taxPrice = json['tax_price'];
    total = json['total'];
    userCar =
        json['userCar'] != null ? UserCar.fromJson(json['userCar']) : null;
    if (json['statueses'] != null) {
      statueses = <Statueses>[];
      json['statueses'].forEach((v) {
        statueses!.add(Statueses.fromJson(v));
      });
    }
    rate = json['rate'];
    fromLat = json['from_lat'];
    fromLon = json['from_lon'];
    toLat = json['to_lat'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    toLon = json['to_lon'];
    fromText = json['from_text'];
    toText = json['to_text'];
    distanceInMeters = json['distance_in_meters'];
    durationInMinutes = json['duration_in_minutes'];
    vendor = json['vendor'] != null ? Brand.fromJson(json['vendor']) : null;
    worker = json['worker'] != null ? Worker.fromJson(json['worker']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['payment_method'] = paymentMethod;
    data['services_price'] = servicesPrice;
    data['tax_price'] = taxPrice;
    data['total'] = total;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (userCar != null) {
      data['userCar'] = userCar!.toJson();
    }
    if (statueses != null) {
      data['statueses'] = statueses!.map((v) => v.toJson()).toList();
    }
    data['rate'] = rate;
    data['from_lat'] = fromLat;
    data['from_lon'] = fromLon;
    data['to_lat'] = toLat;
    data['to_lon'] = toLon;
    data['from_text'] = fromText;
    data['to_text'] = toText;
    data['distance_in_meters'] = distanceInMeters;
    data['duration_in_minutes'] = durationInMinutes;
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    if (worker != null) {
      data['worker'] = worker!.toJson();
    }
    return data;
  }
}

class UserCar {
  int? id;
  bool? isDefault;
  Car? car;

  UserCar({this.id, this.isDefault, this.car});

  UserCar.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isDefault = json['is_default'];
    car = json['car'] != null ? Car.fromJson(json['car']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['is_default'] = isDefault;
    if (car != null) {
      data['car'] = car!.toJson();
    }
    return data;
  }
}

class Car {
  int? id;
  String? year;
  String? engine;
  Model? model;

  Car({this.id, this.year, this.engine, this.model});

  Car.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    year = json['year'];
    engine = json['engine'];
    model = json['model'] != null ? Model.fromJson(json['model']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['year'] = year;
    data['engine'] = engine;
    if (model != null) {
      data['model'] = model!.toJson();
    }
    return data;
  }
}

class Model {
  int? id;
  String? name;
  Brand? brand;

  Model({this.id, this.name, this.brand});

  Model.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    return data;
  }
}

class Brand {
  int? id;
  String? name;

  Brand({this.id, this.name});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Statueses {
  String? status;
  String? time;

  Statueses({this.status, this.time});

  Statueses.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['time'] = time;
    return data;
  }
}

class Worker {
  int? id;
  String? name;
  String? phone;

  Worker({this.id, this.name, this.phone});

  Worker.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;

  User({this.id, this.name, this.email, this.phone});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }}
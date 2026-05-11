import 'package:flutter/material.dart';
import 'package:ma7lola_vendor/core/local_orders/database.dart';
import 'package:ma7lola_vendor/model/products_model.dart';
import 'package:ma7lola_vendor/model/tires_products_model.dart';

import '../model/batteries_products_model.dart';

class ProductsProvider extends ChangeNotifier {
  List<Products> products = [];
  List<Batteries> batteries = [];
  List<Tires> tires = [];

  addIncrementProduct(Products product) {
    if (products.contains(product)) {
      products.add(product);
      product.qty = product.qty! + 1;
    } else {
      products.add(product);
      product.qty = 1;
    }
    notifyListeners();
  }

  decrementProduct(Products product) {
    if (products.contains(product)) {
      products.remove(product);
      if (product.qty! >= 1) {
        product.qty = product.qty! - 1;
      } else {
        product.qty = 0;
      }
    }
    notifyListeners();
  }

  addIncrementBatteries(Batteries battery) async {
    if (batteries.contains(battery)) {
      batteries.add(battery);
      await SQLHelper.updateOrder(
          battery.id!, battery.id!, battery.qty! + 1, 0);
      battery.qty = battery.qty! + 1;
    } else {
      batteries.add(battery);
      await SQLHelper.addOrder(battery.id!, 1, 0);
      battery.qty = 1;
    }
    notifyListeners();
  }

  decrementBatteries(Batteries battery) async {
    if (batteries.contains(battery)) {
      batteries.remove(battery);
      if (battery.qty! >= 1) {
        await SQLHelper.updateOrder(
            battery.id!, battery.id!, battery.qty! - 1, 0);
        battery.qty = battery.qty! - 1;
      } else {
        await SQLHelper.deleteOrder(battery.id!);
        battery.qty = 0;
      }
    }
    notifyListeners();
  }

  addIncrementTires(Tires tire) {
    if (tires.contains(tire)) {
      tires.add(tire);
      tire.qty = tire.qty! + 1;
    } else {
      tires.add(tire);
      tire.qty = 1;
    }
    notifyListeners();
  }

  decrementTires(Tires tire) {
    if (tires.contains(tire)) {
      tires.remove(tire);
      if (tire.qty! >= 1) {
        tire.qty = tire.qty! - 1;
      } else {
        tire.qty = 0;
      }
    }
    notifyListeners();
  }

  clear() async {
    tires.clear();
    tires = [];
    batteries.clear();
    batteries = [];
    products.clear();
    products = [];
    await SQLHelper.cleanAllOrders();
    notifyListeners();
  }
}

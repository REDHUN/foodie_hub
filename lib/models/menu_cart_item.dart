import 'package:foodiehub/models/menu_item.dart';

class MenuCartItem {
  final MenuItem menuItem;
  int quantity;

  MenuCartItem({required this.menuItem, this.quantity = 1});

  double get total => menuItem.price * quantity;

  Map<String, dynamic> toJson() {
    return {'menuItem': menuItem.toJson(), 'quantity': quantity};
  }

  factory MenuCartItem.fromJson(Map<String, dynamic> json) {
    return MenuCartItem(
      menuItem: MenuItem.fromJson(json['menuItem']),
      quantity: json['quantity'],
    );
  }
}

class MenuEntity {
  const MenuEntity({
    required this.id,
    required this.name,
    required this.placeId,
  });

  final int id;
  final String name;
  final int placeId;
}
class MenuItemOptionEntity {
  const MenuItemOptionEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.menuId,
  });

  final int id;
  final String name;
  final double price;
  final int menuId;
}